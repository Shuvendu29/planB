# SME Reward System - Quick Start Guide

## 📋 What Was Implemented

A complete reward and wallet system for Subject Matter Experts (SMEs) in your Exam Prep App with three earning streams:

1. **Approval Rewards** - When admin approves content
2. **Content Type Rewards** - Different amounts per content type
3. **Usage-Based Rewards** - When content reaches 100+ user threshold

---

## 📁 Files Created

### Models (in `lib/models/`)
```
├── sme_wallet_model.dart           # SME wallet tracking
├── reward_config_model.dart        # Admin-set reward amounts
├── reward_transaction_model.dart   # Reward transaction history
└── content_model.dart              # UPDATED: Added reward fields
```

### Providers (in `lib/providers/`)
```
└── reward_provider.dart            # Core reward system logic
```

### Documentation (in project root)
```
├── SME_REWARD_SYSTEM_DOCUMENTATION.md      # Complete system guide
├── SME_REWARD_IMPLEMENTATION_EXAMPLES.md   # Code samples for integration
└── FIRESTORE_SECURITY_RULES.md             # Security rules
```

---

## ⚡ Quick Integration Steps

### Step 1: Add RewardProvider to main.dart

```dart
import 'package:provider/provider.dart';
import 'lib/providers/reward_provider.dart';

MultiProvider(
  providers: [
    // ... existing providers
    ChangeNotifierProvider(create: (_) => RewardProvider()),
  ],
  child: MyApp(),
)
```

### Step 2: Load Reward Configuration on App Start

```dart
void initState() {
  super.initState();
  final rewardProvider = Provider.of<RewardProvider>(context, listen: false);
  rewardProvider.loadRewardConfig();
}
```

### Step 3: Integrate with Admin Approval

In your admin content approval flow:
```dart
await rewardProvider.giveApprovalReward(
  smeUid: content.uploadedBy,
  content: content,
  adminUid: adminUid,
);
```

### Step 4: Track Content Usage

When user completes content:
```dart
await rewardProvider.trackContentUsage(contentId);

// Check if threshold reached and give reward
await rewardProvider.checkAndGiveUsageReward(
  smeUid: smeUid,
  content: contentModel,
);
```

### Step 5: Display SME Wallet & Earnings

```dart
final rewardProvider = Provider.of<RewardProvider>(context);
Text('Balance: ₹${rewardProvider.getAvailableBalance()}');
```

### Step 6: Set Up Admin CMS for Reward Configuration

```dart
await rewardProvider.updateRewardConfig(
  adminUid: adminUid,
  newApprovalReward: 150.0,
  newContentTypeRewards: {
    'mock_test': 600.0,
    'entrance_exam': 1200.0,
    // ... etc
  },
);
```

---

## 🔄 Reward Flow: Step by Step

### Scenario: SME uploads Mock Test

```
1. SME uploads mock test content
   ↓
2. Admin reviews content
   ↓
3. Admin clicks "Approve" 
   ↓
   ✓ Content approved in DB
   ✓ giveApprovalReward() called
   ✓ RewardTransaction created
   ✓ SME wallet +₹500
   ✓ content.rewardGiven = true
   ↓
4. SME notifications: "Approved! +₹500"
```

### Scenario: 100+ Users Complete Mock Test

```
1. Users start completing mock test
   ↓
2. Each completion calls trackContentUsage()
   ↓
3. userCompletionCount increments
   ↓
4. Count reaches 100 → checkAndGiveUsageReward() triggered
   ↓
   ✓ Reward = ₹10 × 100 users = ₹1000
   ✓ RewardTransaction created
   ✓ SME wallet +₹1000
   ✓ content.usageRewardGiven = true
   ↓
5. SME notifications: "Usage milestone! +₹1000"
```

---

## 💰 Default Reward Configuration

```
Approval Reward (Base):           ₹100

Content Type Rewards:
  - Mock Test:                    ₹500
  - Entrance Exam:                ₹1000
  - Study Notes:                  ₹100
  - Current Affairs:              ₹50

Usage-Based Rewards:
  - Per User:                     ₹10
  - Threshold:                    100 users
```

**Example**: SME creates and 150 users complete a mock test
```
Total Earned = ₹500 (approval) + (₹10 × 150 users) = ₹2000
```

---

## 🔐 Firestore Collection Structure

```
database/
├── reward_config/
│   └── default                    # Admin-configured amounts
├── sme_wallets/
│   ├── {smeUid_1}                # SME wallet records
│   └── {smeUid_2}
├── reward_transactions/
│   ├── {txn_id_1}                # Immutable reward history
│   └── {txn_id_2}
└── content/
    └── {contentId}               # UPDATED: with reward fields
```

---

## 📊 RewardProvider Methods Reference

### For SMEs

```dart
// Load wallet data
await rewardProvider.loadSMEWallet(smeUid);

// Load transaction history
await rewardProvider.loadTransactionHistory(smeUid);

// Get balance
double balance = rewardProvider.getAvailableBalance();

// Get total earnings
double earned = rewardProvider.getTotalEarnings();

// Access wallet
SMEWalletModel? wallet = rewardProvider.smeWallet;

// Access history
List<RewardTransactionModel> txns = rewardProvider.transactions;
```

### For Admins

```dart
// Load reward config
await rewardProvider.loadRewardConfig();

// Update reward amounts
await rewardProvider.updateRewardConfig(
  adminUid: adminUid,
  newApprovalReward: 200.0,
  newContentTypeRewards: {...},
  newUsageRewardPerUser: 15.0,
  newUsageThreshold: 150,
);

// Access current config
RewardConfigModel? config = rewardProvider.rewardConfig;
```

### System Operations

```dart
// Give approval reward (triggered by admin approval)
await rewardProvider.giveApprovalReward(
  smeUid: smeUid,
  content: contentModel,
  adminUid: adminUid,
);

// Track user engagement
await rewardProvider.trackContentUsage(contentId);

// Check and give usage reward
await rewardProvider.checkAndGiveUsageReward(
  smeUid: smeUid,
  content: contentModel,
);
```

---

## ✅ Implementation Checklist

- [ ] Add RewardProvider to main.dart providers list
- [ ] Copy security rules to Firestore
- [ ] Initialize reward config on app start
- [ ] Add approval reward logic to admin approval handler
- [ ] Add usage tracking when content is accessed/completed
- [ ] Create SME earnings dashboard screen
- [ ] Create admin reward configuration CMS screen
- [ ] Test approval → reward flow
- [ ] Test usage threshold → reward flow
- [ ] Display wallet balance in SME profile
- [ ] Test security rules in Firestore

---

## 📚 Documentation Files

1. **SME_REWARD_SYSTEM_DOCUMENTATION.md** - Complete technical documentation
2. **SME_REWARD_IMPLEMENTATION_EXAMPLES.md** - Code examples for each screen
3. **FIRESTORE_SECURITY_RULES.md** - Security and Cloud Functions setup

---

## 🚀 Next Features to Consider

- Wallet withdrawal/payment system
- Reward history filters (by type, date range)
- SME performance analytics dashboard
- Bulk reward adjustments by admin
- Reward notifications/alerts
- Tax/form reporting
- Weekly/monthly earning statements

---

## 📞 Key Model Fields Summary

### SMEWalletModel
```dart
totalEarnings        // Total earned (sum of all rewards)
availableBalance     // Available to withdraw
totalWithdrawn       // Total already withdrawn
```

### ContentModel (NEW FIELDS)
```dart
rewardGiven          // Approval reward status
approvalRewardAmount // Amount given for approval
userCompletionCount  // Track usage/engagement
usageRewardGiven     // Usage threshold reward status
usageRewardAmount    // Amount given for usage
```

### RewardTransactionModel
```dart
rewardType           // 'approval' | 'usage_threshold' | 'content_creation'
amount              // Amount earned
description         // Human-readable reason
metadata            // Additional context (contentTitle, userCount, etc.)
```

---

## 🐛 Common Issues & Solutions

**Q: SME not getting reward on approval?**
- Ensure `giveApprovalReward()` is called in your approval handler
- Check wallet exists: `await rewardProvider.loadSMEWallet(smeUid)`

**Q: Usage reward not triggering at threshold?**
- Ensure `trackContentUsage()` is called when content is accessed
- Verify threshold in config: `rewardProvider.rewardConfig?.usageThresholdForReward`

**Q: Cannot update reward config?**
- Check admin role in database: `user.role == 'admin'`
- Ensure security rules allow admin writes

**Q: Rewards disappearing after app restart?**
- This won't happen - rewards are persisted in Firestore
- Use `loadSMEWallet()` and `loadTransactionHistory()` to refresh

---

**System Version**: 1.0  
**Created**: April 8, 2026  
**Status**: Ready for Integration
