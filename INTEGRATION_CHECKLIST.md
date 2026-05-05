# SME Reward System - Integration Checklist

Follow these steps to fully integrate the reward system into your app.

---

## Phase 1: Setup (30 mins)

### 1.1 Provider Registration
- [ ] Open `lib/main.dart`
- [ ] Add import: `import 'package:provider/provider.dart';`
- [ ] Add to providers list:
  ```dart
  ChangeNotifierProvider(create: (_) => RewardProvider()),
  ```

### 1.2 Initialize on App Start
- [ ] In your main app widget's initState (or similar startup logic)
- [ ] Add:
  ```dart
  final rewardProvider = Provider.of<RewardProvider>(context, listen: false);
  await rewardProvider.loadRewardConfig();
  ```

### 1.3 Firestore Setup
- [ ] Go to Firebase Console → Firestore
- [ ] Copy security rules from `FIRESTORE_SECURITY_RULES.md`
- [ ] Paste into Firestore → Rules tab
- [ ] Publish rules

---

## Phase 2: Admin Workflows (1-2 hours)

### 2.1 Reward Configuration CMS Screen
- [ ] Create new screen: `lib/screens/admin/reward_config_screen.dart`
- [ ] Copy code from `SME_REWARD_IMPLEMENTATION_EXAMPLES.md` → Example 3
- [ ] Add route to admin navigation
- [ ] Test updating reward amounts
- [ ] Verify changes appear in real-time

### 2.2 Content Approval Integration
- [ ] Open your admin content approval screen
- [ ] In the approval handler method, add:
  ```dart
  final rewardProvider = Provider.of<RewardProvider>(context, listen: false);
  
  // Give SME approval reward
  bool rewarded = await rewardProvider.giveApprovalReward(
    smeUid: content.uploadedBy,
    content: content,
    adminUid: getCurrentAdminUid(),
  );
  
  if (rewarded) {
    // Show success message to admin
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('SME has been rewarded!')),
    );
  }
  ```
- [ ] Test: Approve a piece of content and verify SME wallet updated

---

## Phase 3: SME Features (1-2 hours)

### 3.1 SME Earnings Dashboard
- [ ] Create screen: `lib/screens/sme/earnings_dashboard_screen.dart`
- [ ] Copy code from `SME_REWARD_IMPLEMENTATION_EXAMPLES.md` → Example 2
- [ ] Show wallet balance prominently
- [ ] Show transaction history with reward types
- [ ] Add to SME navigation menu

### 3.2 SME Profile Integration
- [ ] Add wallet balance display to SME profile screen
- [ ] Link to full earnings dashboard
- [ ] Show quick stats: Total Earned, Available Balance

### 3.3 Test SME Features
- [ ] [ ] Log in as SME
- [ ] [ ] Upload content
- [ ] [ ] Have admin approve it
- [ ] [ ] Verify wallet updated
- [ ] [ ] Check transaction history

---

## Phase 4: User Engagement Tracking (1 hour)

### 4.1 Content Completion Handler
- [ ] Find where users complete content (mock test, study notes, etc.)
- [ ] After successful completion, add:
  ```dart
  final rewardProvider = Provider.of<RewardProvider>(context, listen: false);
  
  // Track that a user completed this content
  await rewardProvider.trackContentUsage(contentId);
  ```

### 4.2 Usage Reward Trigger
- [ ] Add timer or background job that periodically checks
- [ ] (Or check when relevant admin opens analytics)
- [ ] Add:
  ```dart
  // After loading a content
  final rewardProvider = Provider.of<RewardProvider>(context, listen: false);
  
  // Check if threshold reached and give usage reward
  await rewardProvider.checkAndGiveUsageReward(
    smeUid: content.uploadedBy,
    content: content,
  );
  ```

### 4.3 Test Usage Rewards
- [ ] Create test content
- [ ] Simulate 100+ user completions (can manually update in Firestore)
- [ ] Verify SME gets usage reward in wallet
- [ ] Verify transaction appears in history

---

## Phase 5: UI Enhancements (30 mins - 1 hour)

### 5.1 Add Reward Notifications
- [ ] Add push notifications for:
  - [ ] Content approved
  - [ ] Reward added
  - [ ] Usage threshold reached
- [ ] Test each notification

### 5.2 Add Rewards to Content View
- [ ] In user content view, show how much SME earned
- [ ] Add info: "This content creator earned ₹1500"

### 5.3 Add Admin Analytics
- [ ] Create admin analytics screen showing:
  - [ ] Total rewards paid this month
  - [ ] Top earning SMEs
  - [ ] Most completed content

---

## Phase 6: Testing & Validation (1-2 hours)

### 6.1 Approval Reward Flow
- [ ] [ ] SME uploads content
- [ ] [ ] Admin approves
- [ ] [ ] Check: Reward transaction created ✅
- [ ] [ ] Check: SME wallet balance updated ✅
- [ ] [ ] Check: Transaction appears in SME history ✅

### 6.2 Usage Reward Flow
- [ ] [ ] Get content with pending usage reward
- [ ] [ ] Simulate 100+ completions
- [ ] [ ] Trigger checkAndGiveUsageReward()
- [ ] [ ] Check: Usage reward transaction created ✅
- [ ] [ ] Check: SME wallet balance updated ✅
- [ ] [ ] Check: Duplicate rewards not given ✅

### 6.3 Multiple SMEs
- [ ] [ ] Create content from 2+ different SMEs
- [ ] [ ] Approve from admin
- [ ] [ ] Verify each SME gets their own reward ✅

### 6.4 Admin Configuration
- [ ] [ ] Update reward amounts from CMS
- [ ] [ ] Verify new amounts used for future approvals ✅
- [ ] [ ] Verify only admins can configure ✅

### 6.5 Security Testing
- [ ] [ ] Non-admin cannot see other SME wallets ✅
- [ ] [ ] SME cannot create fake transactions ✅
- [ ] [ ] Users cannot modify reward amounts ✅

---

## Phase 7: Documentation & Handoff (1 hour)

### 7.1 Document Your Integration
- [ ] Add integration notes to README.md
- [ ] Document any customizations made
- [ ] Note any changes to content flow

### 7.2 Team Training
- [ ] [ ] Train admins on reward configuration
- [ ] [ ] Train support team on wallet inquiries
- [ ] [ ] Show SMEs their earnings dashboard

### 7.3 Launch Preparation
- [ ] [ ] Set initial reward amounts
- [ ] [ ] Announce reward system to SMEs
- [ ] [ ] Monitor for first week

---

## Phase 8: Post-Launch (Ongoing)

### 8.1 Monitor
- [ ] Check Firestore collections are growing
- [ ] Monitor wallet balances
- [ ] Check for any error patterns

### 8.2 Optimize
- [ ] Collect feedback from SMEs
- [ ] Adjust reward amounts based on performance
- [ ] Add more earning opportunities

### 8.3 Advanced Features (Optional)
- [ ] [ ] Withdraw/payment gateway
- [ ] [ ] Reward multipliers (loyalty bonuses)
- [ ] [ ] Team/referral rewards
- [ ] [ ] Seasonal reward adjustments

---

## File Reference

| File | Purpose | Location |
|------|---------|----------|
| sme_wallet_model.dart | Wallet data | `lib/models/` |
| reward_config_model.dart | Configuration | `lib/models/` |
| reward_transaction_model.dart | History | `lib/models/` |
| content_model.dart | Updated content | `lib/models/` |
| reward_provider.dart | Main logic | `lib/providers/` |

---

## Troubleshooting

### Reward Not Given
- [ ] Check admin has 'admin' role in database
- [ ] Verify giveApprovalReward() is being called
- [ ] Check Firestore security rules are published
- [ ] Check for console errors

### Wallet Not Updating
- [ ] Verify loadSMEWallet() is called
- [ ] Check notifyListeners() is called
- [ ] Verify Firestore security rules allow update
- [ ] Check FieldValue.increment() syntax

### Usage Reward Not Triggered
- [ ] Verify trackContentUsage() called each completion
- [ ] Check userCompletionCount in content document
- [ ] Verify threshold value in config
- [ ] Ensure checkAndGiveUsageReward() is being called

### Cannot Update Config
- [ ] Verify user is admin
- [ ] Check security rules allow admin writes
- [ ] Verify updateRewardConfig() parameters are correct
- [ ] Check for validation errors

---

## Quick Commands for Testing

### In Firebase Console

```javascript
// See all wallets
db.collection('sme_wallets').get()

// See all transactions
db.collection('reward_transactions').get()

// See config
db.collection('reward_config').doc('default').get()

// Manually update completion count (for testing)
db.collection('content').doc('test_id').update({
  userCompletionCount: 150
})
```

---

## Success Criteria ✅

After integration, your system should have:

- [x] SMEs earn rewards on approval
- [x] SMEs earn rewards at usage threshold
- [x] Admin can configure all reward amounts
- [x] SMEs can see wallet balance
- [x] SMEs can see transaction history
- [x] Rewards are immutable/auditable
- [x] Security rules prevent unauthorized access
- [x] No duplicate rewards given

---

## Support & Questions

Refer to these documents for detailed help:

1. **QUICK_START_GUIDE.md** - Fast overview
2. **SME_REWARD_SYSTEM_DOCUMENTATION.md** - Complete reference
3. **SME_REWARD_IMPLEMENTATION_EXAMPLES.md** - Code examples
4. **SYSTEM_ARCHITECTURE_VISUAL.md** - Visual diagrams
5. **FIRESTORE_SECURITY_RULES.md** - Security setup

---

**Estimated Total Time**: 4-6 hours for full integration

Good luck with your implementation! 🚀
