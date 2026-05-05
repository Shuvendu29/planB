# SME Reward & Wallet System Implementation

## Overview
This document outlines the complete implementation of the SME (Subject Matter Expert) reward and wallet system for the Exam Preparation App.

## System Architecture

### Three Earning Mechanisms

#### 1. **Approval Reward** ✅
- **Trigger**: When admin approves submitted content
- **Amount**: Configured per content type (default base: ₹100)
- **When Given**: Immediately upon approval
- **Example**: 
  - Mock Test Approval → ₹500 (configurable)
  - Study Notes Approval → ₹100 (configurable)

#### 2. **Content Creation Reward** ✅
- **Trigger**: When content is first approved
- **Amount**: Based on content type
- **Configured in**: Reward Configuration (CMS)
- **Types**:
  - `mock_test`: ₹500
  - `entrance_exam`: ₹1000
  - `study_notes`: ₹100
  - `current_affairs`: ₹50

#### 3. **Usage-Based Reward** ✅
- **Trigger**: When content usage reaches threshold (100+ users by default)
- **Amount**: ₹10 per user × user count
- **Example**: If 100 users complete a mock test → ₹10 × 100 = ₹1000
- **Configurable**: 
  - `usageRewardPerUser`: Amount per user
  - `usageThresholdForReward`: Threshold count (default: 100)

## Models

### 1. **SMEWalletModel** (`sme_wallet_model.dart`)
```dart
Tracks:
- totalEarnings: Total amount earned (sum of all rewards)
- availableBalance: Current wallet balance (spendable amount)
- totalWithdrawn: Total amount withdrawn
- createdAt: When wallet was created
- lastUpdatedAt: Last transaction time
```

**Firestore Path**: `sme_wallets/{smeUid}`

### 2. **RewardConfigModel** (`reward_config_model.dart`)
```dart
Configuration stored by Admin:
- approvalReward: Base reward for approval (₹100 default)
- contentTypeRewards: Type-specific amounts (dict)
- usageRewardPerUser: ₹/user for usage rewards
- usageThresholdForReward: Min users for reward (100 default)
- isActive: Enable/disable rewards
- updatedBy: Admin who made changes
```

**Firestore Path**: `reward_config/default`

### 3. **RewardTransactionModel** (`reward_transaction_model.dart`)
```dart
Tracks each reward transaction:
- smeName: SME uid who earned
- contentId: Associated content
- rewardType: 'approval' | 'content_creation' | 'usage_threshold'
- amount: ₹ amount given
- status: 'pending' | 'completed'
- metadata: Additional info (content title, user count, etc.)
```

**Firestore Path**: `reward_transactions/{transactionId}`

### 4. **Updated ContentModel** (`content_model.dart`)
```dart
New fields for reward tracking:
- rewardGiven: bool - Whether approval reward disbursed
- approvalRewardAmount: double - Amount of approval reward
- userCompletionCount: int - How many users accessed content
- usageRewardGiven: bool - Whether usage reward disbursed
- usageRewardAmount: double - Amount of usage reward
```

## Provider: RewardProvider

### Key Methods

#### **loadRewardConfig()**
Load current reward configuration from CMS
```dart
await rewardProvider.loadRewardConfig();
// Access: rewardProvider.rewardConfig
```

#### **loadSMEWallet(String smeUid)**
Load SME wallet and balance
```dart
await rewardProvider.loadSMEWallet(smeUid);
// Access: rewardProvider.smeWallet
//         rewardProvider.getAvailableBalance()
//         rewardProvider.getTotalEarnings()
```

#### **giveApprovalReward({...})**
Called when admin approves content
```dart
bool success = await rewardProvider.giveApprovalReward(
  smeUid: 'sme_uid_123',
  content: contentModel,
  adminUid: 'admin_uid_456',
);
// Automatically:
// 1. Creates reward transaction
// 2. Updates SME wallet
// 3. Marks content as rewarded
```

#### **trackContentUsage(String contentId)**
Track when user completes content (increment counter)
```dart
await rewardProvider.trackContentUsage(contentId);
```

#### **checkAndGiveUsageReward({...})**
Check if threshold reached and give usage reward
```dart
bool rewarded = await rewardProvider.checkAndGiveUsageReward(
  smeUid: 'sme_uid_123',
  content: contentModel,
);
```

#### **loadTransactionHistory(String smeUid)**
Get all reward transactions for SME
```dart
await rewardProvider.loadTransactionHistory(smeUid);
// Access: rewardProvider.transactions (List<RewardTransactionModel>)
```

#### **updateRewardConfig({...})**
Admin-only method to update amounts in CMS
```dart
bool success = await rewardProvider.updateRewardConfig(
  adminUid: 'admin_uid_456',
  newApprovalReward: 150.0,
  newContentTypeRewards: {
    'mock_test': 600.0,
    'entrance_exam': 1200.0,
    'study_notes': 120.0,
    'current_affairs': 60.0,
  },
  newUsageRewardPerUser: 15.0,
  newUsageThreshold: 150,
);
```

## Firestore Collections Structure

```
└── reward_config/
    └── default
        ├── approvalReward: 100
        ├── contentTypeRewards: {mock_test: 500, entrance_exam: 1000, ...}
        ├── usageRewardPerUser: 10
        ├── usageThresholdForReward: 100
        ├── isActive: true
        ├── createdAt: timestamp
        ├── updatedAt: timestamp
        └── updatedBy: admin_uid

├── sme_wallets/
│   └── {smeUid}
│       ├── totalEarnings: 5000
│       ├── availableBalance: 4500
│       ├── totalWithdrawn: 500
│       ├── createdAt: timestamp
│       └── lastUpdatedAt: timestamp

└── reward_transactions/
    ├── {transactionId_1}
    │   ├── smeUid: sme_uid_123
    │   ├── contentId: content_456
    │   ├── rewardType: 'approval'
    │   ├── amount: 500
    │   ├── description: 'Reward for mock test approval'
    │   ├── status: 'completed'
    │   ├── createdAt: timestamp
    │   └── metadata: {contentTitle: 'Physics Mock Test', ...}
    │
    └── {transactionId_2}
        ├── smeUid: sme_uid_123
        ├── contentId: content_456
        ├── rewardType: 'usage_threshold'
        ├── amount: 1000
        ├── description: 'Usage reward for Physics Mock Test (100 users)'
        ├── status: 'completed'
        └── metadata: {userCount: 100, rewardPerUser: 10, ...}
```

## Integration Points

### 1. **Admin Approval Screen**
When admin approves content:
```dart
// In admin content approval handler
final rewardProvider = Provider.of<RewardProvider>(context, listen: false);

// Approve content in Firestore
await approveContent(contentId, adminUid);

// Give SME reward
await rewardProvider.giveApprovalReward(
  smeUid: content.uploadedBy,
  content: content,
  adminUid: adminUid,
);

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Content approved! SME rewarded ₹${content.approvalRewardAmount}')),
);
```

### 2. **SME Dashboard**
Display wallet balance and earnings:
```dart
// Load SME data
await rewardProvider.loadSMEWallet(currentUserUid);
await rewardProvider.loadTransactionHistory(currentUserUid);

// In build:
Column(
  children: [
    Text('Available Balance: ₹${rewardProvider.getAvailableBalance()}'),
    Text('Total Earnings: ₹${rewardProvider.getTotalEarnings()}'),
    // List transactions
    ListView.builder(
      itemCount: rewardProvider.transactions.length,
      itemBuilder: (context, index) {
        final transaction = rewardProvider.transactions[index];
        return ListTile(
          title: Text(transaction.description),
          subtitle: Text(transaction.rewardType),
          trailing: Text('+ ₹${transaction.amount}'),
        );
      },
    ),
  ],
)
```

### 3. **Admin CMS - Reward Configuration**
Update reward amounts:
```dart
// Create form inputs for configurable values
TextFormField(
  initialValue: rewardProvider.rewardConfig?.approvalReward.toString() ?? '100',
  label: 'Approval Reward (₹)',
  onChanged: (value) {
    // Store in variable for submission
  },
)

// On save:
await rewardProvider.updateRewardConfig(
  adminUid: currentAdminUid,
  newApprovalReward: double.parse(approvalRewardController.text),
  newContentTypeRewards: updatedTypeRewards,
  newUsageRewardPerUser: double.parse(usagePerUserController.text),
  newUsageThreshold: int.parse(thresholdController.text),
);
```

### 4. **User Completion Tracking**
When user completes a mock test/content:
```dart
// After user completes test
await rewardProvider.trackContentUsage(contentId);

// Periodically check if threshold reached
final updatedContent = await fetchContent(contentId);
await rewardProvider.checkAndGiveUsageReward(
  smeUid: updatedContent.uploadedBy,
  content: updatedContent,
);
```

## Security Rules (Firestore)

### SME Wallets
```
- SMEs can only read their own wallet
- Only reward provider (backend) can write
```

### Reward Transactions
```
- SMEs can only read their own transactions
- Only reward provider can write
```

### Reward Config
```
- Anyone can read (needed for calculations)
- Only admins can write
```

## Flow Diagrams

### Content Approval Flow
```
Admin approves content
  ↓
giveApprovalReward() called
  ↓
1. Create RewardTransaction
2. Update SME wallet (availableBalance +, totalEarnings +)
3. Mark content.rewardGiven = true
4. Update content.approvalRewardAmount
  ↓
SME wallet updated with ₹500 (example)
```

### Usage Reward Flow
```
Each user completes content
  ↓
trackContentUsage() increments counter
  ↓
userCompletionCount reaches 100 (threshold)
  ↓
checkAndGiveUsageReward() called
  ↓
1. Create RewardTransaction (₹10 × 100 = ₹1000)
2. Update SME wallet
3. Mark content.usageRewardGiven = true
4. Update content.usageRewardAmount
  ↓
SME wallet updated with ₹1000
```

## Default Configuration

If no config exists, system uses defaults:
```
approvalReward: ₹100
contentTypeRewards:
  - mock_test: ₹500
  - entrance_exam: ₹1000
  - study_notes: ₹100
  - current_affairs: ₹50
usageRewardPerUser: ₹10
usageThresholdForReward: 100 users
```

## Error Handling

- Duplicate rewards prevented: `rewardGiven` flag checks
- Transaction failures logged and reported
- Wallet consistency maintained via FieldValue.increment()
- Non-existent wallets auto-created on first access

## Next Steps for Integration

1. **Add to providers setup** in `main.dart`:
   ```dart
   ChangeNotifierProvider(create: (_) => RewardProvider()),
   ```

2. **Update content approval flow** in admin screens

3. **Add reward info to SME dashboard**

4. **Create CMS admin panel** for reward configuration

5. **Implement transaction history UI** showing rewards earned

6. **Add usage tracking** when content is accessed/completed

---

**Version**: 1.0  
**Created**: 2026-04-08
