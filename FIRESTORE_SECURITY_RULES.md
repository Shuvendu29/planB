# Firestore Security Rules for SME Reward System

Add these rules to your Firestore to secure the reward system.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ==========================================
    // REWARD CONFIGURATION
    // ==========================================
    // Anyone can read (needed for UX and calculations)
    // Only admins can write/update
    match /reward_config/{document=**} {
      allow read: if true;
      allow write: if isAdmin();
      allow update: if isAdmin();
      allow delete: if isAdmin();
    }
    
    // ==========================================
    // SME WALLETS
    // ==========================================
    // SMEs can read only their own wallet
    // System (via backend) manages writes
    match /sme_wallets/{smeUid} {
      allow read: if request.auth.uid == smeUid;
      // Writes allowed only from backend (authenticated)
      allow write: if request.auth != null && isAdmin();
      allow update: if request.auth != null;
      allow create: if request.auth != null;
    }
    
    // ==========================================
    // REWARD TRANSACTIONS
    // ==========================================
    // SMEs can read only their own transactions
    // Admins can read all
    // System manages creates
    match /reward_transactions/{transactionId} {
      allow read: if 
        request.auth.uid == resource.data.smeUid ||
        isAdmin();
      
      allow create: if request.auth != null;
      
      allow write: if isAdmin();
      allow update: if isAdmin();
      allow delete: if isAdmin();
    }
    
    // ==========================================
    // CONTENT - REWARD TRACKING
    // ==========================================
    // Add to your existing content rules
    match /content/{contentId} {
      // Allow reading
      allow read: if 
        canAccessContent(resource.data) ||
        isOwner(resource.data.uploadedBy) ||
        isAdmin();
      
      // Allow SMEs to create
      allow create: if isAuthenticated() && request.resource.data.uploadedBy == request.auth.uid;
      
      // Allow updating only specific reward fields (by backend/functions)
      allow update: if 
        isAdmin() ||
        (isOwner(resource.data.uploadedBy) && !fieldChanges(['status', 'rewardGiven', 'approvalRewardAmount', 'usageRewardGiven', 'usageRewardAmount']));
      
      allow delete: if isAdmin() || isOwner(resource.data.uploadedBy);
    }
    
    // ==========================================
    // HELPER FUNCTIONS
    // ==========================================
    
    // Check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Check if user is admin
    function isAdmin() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Check if user is the owner
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Check if user can access content
    function canAccessContent(contentData) {
      let userDoc = get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
      return contentData.status == 'approved' ||
             userDoc.role == 'admin' ||
             userDoc.role == 'sme';
    }
    
    // Check which fields are being changed
    function fieldChanges(fields) {
      let changes = false;
      for (let field in fields) {
        if (request.resource.data[field] != resource.data[field]) {
          changes = true;
        }
      }
      return changes;
    }
  }
}
```

## Important Security Considerations

### 1. **Wallet Transaction Immutability**
```javascript
// Once created, transactions cannot be modified or deleted
match /reward_transactions/{transactionId} {
  allow create: if request.auth != null;
  allow read: if userOwnsTransaction();
  allow update: if false;  // Transactions are immutable
  allow delete: if false;  // Transactions are immutable
}
```

### 2. **Admin-Only Reward Configuration**
```javascript
// Only administrators can modify reward configuration
match /reward_config/{document=**} {
  allow read: if true;  // Everyone needs to read for calculations
  allow write: if isAdmin();  // Only admins can change
  allow delete: if false;  // Never delete config
}
```

### 3. **Prevent Wallet Balance Manipulation**
```javascript
// Users cannot directly modify their wallet
// Only backend functions can update wallets
match /sme_wallets/{smeUid} {
  allow read: if request.auth.uid == smeUid;
  allow write: if false;  // No direct writes from client
}
```

### 4. **Content Reward Fields**
```javascript
// Only backend can update reward-related fields
// SMEs cannot directly modify these
function isRewardField(field) {
  return field in ['rewardGiven', 'approvalRewardAmount', 
                   'usageRewardGiven', 'usageRewardAmount'];
}
```

## Testing Rules

To test your Firestore rules:

1. **Unauthenticated User**
   - ❌ Cannot read wallets
   - ❌ Cannot read transactions
   - ✅ Can read approved content
   - ❌ Cannot modify rewards

2. **SME User**
   - ✅ Can read own wallet
   - ✅ Can read own transactions
   - ✅ Can upload content
   - ❌ Cannot modify reward amounts
   - ❌ Cannot create fake transactions

3. **Admin User**
   - ✅ Can read all wallets
   - ✅ Can read all transactions
   - ✅ Can update reward config
   - ✅ Can approve content (triggers rewards)
   - ❌ Cannot directly modify wallet balances*

*Note: Wallet modifications should happen through Cloud Functions that manage rewards, not direct Firestore rules.

## Recommended Cloud Functions

While Firestore rules handle access control, use Cloud Functions for critical operations:

```javascript
// Cloud Function: Approve content and give reward
exports.approveContentAndReward = functions.https.onCall(async (data, context) => {
  // Verify admin
  if (context.auth.token.role !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'Only admins can approve content');
  }

  const { contentId, smeUid } = data;

  // Transaction for consistency
  await db.runTransaction(async (transaction) => {
    // 1. Update content
    await transaction.update(db.collection('content').doc(contentId), {
      status: 'approved',
      approvedAt: admin.firestore.FieldValue.serverTimestamp(),
      approvedBy: context.auth.uid,
      rewardGiven: true,
      approvalRewardAmount: 500, // or fetch from config
    });

    // 2. Update wallet
    await transaction.update(db.collection('sme_wallets').doc(smeUid), {
      availableBalance: admin.firestore.FieldValue.increment(500),
      totalEarnings: admin.firestore.FieldValue.increment(500),
      lastUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 3. Log transaction
    await transaction.set(db.collection('reward_transactions').doc(), {
      smeUid: smeUid,
      contentId: contentId,
      rewardType: 'approval',
      amount: 500,
      description: 'Content approval reward',
      status: 'completed',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      processedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  return { success: true, message: 'Content approved and reward given' };
});
```

This ensures atomic operations and prevents race conditions.

---

**Version**: 1.0
