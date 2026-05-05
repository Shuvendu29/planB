# SME Reward System - Visual Architecture

## System Overview Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    EXAM PREPARATION APP                      │
│                   (Flutter + Firestore)                      │
└─────────────────────────────────────────────────────────────┘
                              │
                ┌─────────────┼─────────────┐
                ▼             ▼             ▼
            ┌─────┐       ┌──────┐     ┌──────┐
            │ SME │       │ADMIN │     │ USER │
            └─────┘       └──────┘     └──────┘
                ▲             ▲             ▲
                │             │             │
    ┌───────────┴─────────────┴─────────────┴───────────┐
    │                                                    │
    │         REWARD PROVIDER (Core Logic)              │
    │  ┌──────────────────────────────────────────────┐ │
    │  │  √ loadRewardConfig()                        │ │
    │  │  √ loadSMEWallet()                           │ │
    │  │  √ giveApprovalReward()                      │ │
    │  │  √ trackContentUsage()                       │ │
    │  │  √ checkAndGiveUsageReward()                 │ │
    │  │  √ updateRewardConfig()                      │ │
    │  └──────────────────────────────────────────────┘ │
    └────────────┬─────────────────────────────────────┘
                 │
    ┌────────────┴────────────────────────────┐
    ▼                                          ▼
┌──────────────────┐              ┌──────────────────┐
│  FIRESTORE DB    │              │ SECURITY RULES   │
├──────────────────┤              ├──────────────────┤
│ reward_config/   │              │ Admin-only CMS   │
│    {default}     │              │ Role-based access│
├──────────────────┤              │ Immutable txns   │
│ sme_wallets/     │              │ Protected fields │
│   {smeUid}       │              └──────────────────┘
├──────────────────┤
│ reward_txns/     │
│ {transactionId}  │
├──────────────────┤
│ content/         │
│ {contentId}      │
└──────────────────┘
```

---

## Three Reward Streams

```
                    ┌─────────────────────────┐
                    │   SME Creates Content   │
                    └────────────┬────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │  Content Pending/Draft │
                    └────────────┬────────────┘
                                 │
          ┌──────────────────────▼──────────────────────┐
          │   Admin Reviews & Approves Content          │
          └────────────┬─────────────────────────────────┘
                       │
        ┌──────────────▼────────────────┐
        │                               │
        │                               │
        ▼                               ▼
   ✓ REWARD #1               ✓ REWARD #2
 Approval Reward          Content Type Reward
   (₹100-1000)            (Based on content type)
   Immediate              Immediate

   Example:               Example:
   Mock Test Approved     Study Notes (+₹100)
   (+₹500)                Exam (+₹1000)
        │                        │
        └────────────┬───────────┘
                     │
            ┌────────▼────────┐
            │  Content Live   │
            │   Users Access  │
            │   Content Usage │
            │   Incrementing  │
            └────────┬────────┘
                     │
        ┌────────────┴──────────────────┐
        │  Usage Reaches Threshold      │
        │  (100+ users by default)      │
        └────────────┬──────────────────┘
                     │
                     ▼
                ✓ REWARD #3
            Usage-Based Reward
             (₹10 per user)
              (on trigger)

              Example:
          100 users completed
        = ₹1000 (100 × ₹10)
               │
               ▼
        ┌─────────────────┐
        │  SME Wallet +$  │
        │   Total Earned  │
        │ + Available BAL │
        └─────────────────┘
```

---

## Data Model Relationships

```
┌──────────────────────────┐
│   REWARD CONFIG          │
│   (Admin Managed)        │
├──────────────────────────┤
│ • approvalReward: 100    │
│ • mockTestReward: 500    │
│ • examReward: 1000       │
│ • studyNotesReward: 100  │
│ • usageRewardPerUser: 10 │
│ • usageThreshold: 100    │
│ • updatedBy: admin_uid   │
└────────────┬─────────────┘
             │
             │ applies to
             ▼
┌──────────────────────────────────────┐
│     CONTENT MODEL (Updated)          │
│     (SME Created)                    │
├──────────────────────────────────────┤
│ id                                   │
│ title                                │
│ type (mock_test, exam, etc)         │
│ uploadedBy: sme_uid                  │
│ status: approved/pending             │
│ • rewardGiven: bool                  │ ← NEW
│ • approvalRewardAmount: 500          │ ← NEW
│ • userCompletionCount: 150           │ ← NEW
│ • usageRewardGiven: bool             │ ← NEW
│ • usageRewardAmount: 1500            │ ← NEW
└────┬──────────────────────────────────┘
     │
     │ logs
     ▼
┌──────────────────────────────────────┐
│   REWARD TRANSACTION                 │
│   (Immutable History)                │
├──────────────────────────────────────┤
│ id                                   │
│ smeUid                               │
│ contentId                            │
│ rewardType:                          │
│  - approval                          │
│  - usage_threshold                   │
│  - content_creation                  │
│ amount: 500 (₹)                     │
│ description: "reason"                │
│ metadata: {...extraInfo}             │
│ status: completed                    │
│ createdAt: timestamp                 │
└────┬──────────────────────────────────┘
     │
     │ updates
     ▼
┌──────────────────────────┐
│   SME WALLET             │
│   (One per SME)          │
├──────────────────────────┤
│ id: sme_uid              │
│ totalEarnings: 2500      │
│ availableBalance: 2000   │
│ totalWithdrawn: 500      │
│ createdAt: date          │
│ lastUpdatedAt: date      │
└──────────────────────────┘
```

---

## Integration Points in Your App

```
┌─────────────────────────────────────────────────────────┐
│                   YOUR APP SCREENS                      │
└─────────────────────────────────────────────────────────┘
                         │
        ┌────────────────┼────────────────┐
        ▼                ▼                ▼
    ┌─────────┐   ┌──────────┐   ┌──────────────┐
    │  ADMIN  │   │   SME    │   │     USER     │
    │ SCREENS │   │ SCREENS  │   │    SCREENS   │
    └────┬────┘   └────┬─────┘   └──────┬───────┘
         │             │                │
         ▼             ▼                ▼
    ┌─────────────┐ ┌──────────────┐ ┌──────────┐
    │ Approve     │ │ Dashboard    │ │ Complete │
    │ Content     │ │  - Wallet    │ │ Content  │
    │ Screen      │ │  - Balance   │ │ Screen   │
    │    │        │ │  - History   │ │    │     │
    │    │        │ │    Screen    │ │    │     │
    │    │        │ └──────────────┘ │    │     │
    │    │        │                  │    │     │
    │ Configure   │ SME Earnings     │    │     │
    │ Rewards     │ Screen           │    │     │
    │    │        │                  │    │     │
    └────┼────────┴──────────────────┴────┼─────┘
         │                                 │
         │                                 │
         └─────────────┬───────────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │   REWARD PROVIDER            │
        │  (RewardProvider class)      │
        │                              │
        │  Methods:                    │
        │  • giveApprovalReward()      │
        │  • trackContentUsage()       │
        │  • checkAndGiveUsageReward() │
        │  • updateRewardConfig()      │
        │  • loadSMEWallet()           │
        │  • loadTransactionHistory()  │
        └──────────────┬───────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │    FIRESTORE DATABASE        │
        │                              │
        │ Collections:                 │
        │ • reward_config/{default}    │
        │ • sme_wallets/{smeUid}       │
        │ • reward_transactions/{}     │
        │ • content/{contentId}        │
        └──────────────────────────────┘
```

---

## Reward Calculation Examples

### Example 1: Single Content, No Usage Threshold

```
SME uploads Mock Test
   ↓
Admin approves Mock Test
   ↓
✓ Approval Reward = ₹500
   ↓
Total for SME: ₹500
```

### Example 2: Content + Usage Threshold

```
SME uploads Study Notes
   ↓
Admin approves Study Notes
   ↓
✓ Approval Reward = ₹100
   ↓
Users complete Study Notes
   ↓
Count reaches 100 users:
   ↓
✓ Usage Reward = ₹10 × 100 = ₹1000
   ↓
Total for SME: ₹100 + ₹1000 = ₹1100
```

### Example 3: Multiple Content Items

```
Month Activity:

Content 1: Mock Test Approved
  → ₹500

Content 2: Exam Approved
  → ₹1000

Content 3: Study Notes Approved
  → ₹100

Content 1: 100 users complete
  → ₹1000

Content 2: 200 users complete
  → ₹2000

Monthly Total: ₹4600
```

---

## State Management Flow

```
Provider Initialization (app start)
        │
        ▼
┌──────────────────────┐
│ RewardProvider()     │
│   - Initialized      │
└──────┬───────────────┘
       │
       │ loadRewardConfig()
       ▼
┌──────────────────────┐
│ _rewardConfig loaded │
└──────┬───────────────┘
       │
       │ loadSMEWallet(smeUid)
       ▼
┌──────────────────────┐
│ _smeWallet loaded    │
└──────┬───────────────┘
       │
       │ loadTransactionHistory()
       ▼
┌──────────────────────┐
│ _transactions loaded │
└──────┬───────────────┘
       │
       ▼
  notifyListeners()
       │
       ▼
UI Updated with:
  • Wallet balance
  • Transaction history
  • Earning totals
```

---

## Security Implementation

```
┌─────────────────────────────────────┐
│     FIRESTORE SECURITY RULES        │
└─────────────────────────────────────┘
                  │
    ┌─────────────┼──────────────┐
    ▼             ▼              ▼
┌────────┐  ┌──────────┐  ┌────────────┐
│        │  │          │  │            │
│ Config │  │ Wallets  │  │Transaction │
│        │  │          │  │            │
│ Anyone │  │ SME Only │  │ SME/Admin  │
│ read   │  │ owned    │  │ read owned │
│        │  │          │  │            │
│ Admin  │  │ Backend  │  │Backend     │
│ write  │  │ increment│  │ write only │
│        │  │          │  │            │
└────────┘  └──────────┘  └────────────┘
```

---

## Firestore Collections Tree

```
firestore/
│
├── reward_config/
│   └── default
│       ├── approvalReward: 100
│       ├── contentTypeRewards: {mock_test: 500, ...}
│       ├── usageRewardPerUser: 10
│       ├── usageThresholdForReward: 100
│       ├── isActive: true
│       ├── createdAt: 2026-04-08...
│       ├── updatedAt: 2026-04-08...
│       └── updatedBy: "admin_uid_123"
│
├── sme_wallets/
│   ├── sme_uid_1/
│   │   ├── totalEarnings: 5000
│   │   ├── availableBalance: 4500
│   │   ├── totalWithdrawn: 500
│   │   ├── createdAt: 2026-01-15...
│   │   └── lastUpdatedAt: 2026-04-08...
│   │
│   └── sme_uid_2/
│       ├── totalEarnings: 12000
│       ├── availableBalance: 11000
│       └── ...
│
├── reward_transactions/
│   ├── txn_001/
│   │   ├── smeUid: "sme_uid_1"
│   │   ├── contentId: "content_123"
│   │   ├── rewardType: "approval"
│   │   ├── amount: 500
│   │   ├── description: "Mock test approval"
│   │   ├── status: "completed"
│   │   ├── createdAt: 2026-03-01...
│   │   └── metadata: {contentTitle: "Physics", ...}
│   │
│   ├── txn_002/
│   │   ├── smeUid: "sme_uid_1"
│   │   ├── contentId: "content_123"
│   │   ├── rewardType: "usage_threshold"
│   │   ├── amount: 1000
│   │   ├── description: "100 users completed"
│   │   └── ...
│   │
│   └── txn_003/
│       └── ...
│
└── content/
    └── content_123/
        ├── title: "Physics Mock Test"
        ├── type: "mock_test"
        ├── uploadedBy: "sme_uid_1"
        ├── status: "approved"
        ├── rewardGiven: true
        ├── approvalRewardAmount: 500
        ├── userCompletionCount: 152
        ├── usageRewardGiven: true
        ├── usageRewardAmount: 1520
        └── ...
```

---

## Flow: From Creation to Reward

```
┌──────────────────────────────────────────────────────────────┐
│ STEP 1: SME CREATES CONTENT                                  │
│ • Uploads file/creates content                               │
│ • Set to "pending" status                                    │
│ • Firestore: content/{id} created                            │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│ STEP 2: ADMIN REVIEWS CONTENT                                │
│ • Admin views pending content                                │
│ • Checks quality, issues approval or rejection               │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
              ┌─────────────┴──────────────┐
              │                            │
         APPROVED                      REJECTED
              │                            │
              ▼                            ▼
    ┌──────────────────┐        ┌─────────────┐
    │ STEP 3: REWARD   │        │ No Reward   │
    │ giveApprovalRew()│        │             │
    └────────┬─────────┘        └─────────────┘
             │
             ├──→ Create RewardTransaction
             │    - rewardType: "approval"
             │    - amount: 500 (per config)
             │
             ├──→ Update sme_wallets
             │    - availableBalance += 500
             │    - totalEarnings += 500
             │
             ├──→ Update content
             │    - rewardGiven = true
             │    - approvalRewardAmount = 500
             │
             └──→ notifyListeners()
                  SME sees wallet updated
              │
              ▼
    ┌──────────────────┐
    │ STEP 4: USERS    │
    │ ACCESS CONTENT   │
    └────────┬─────────┘
             │
             ├──→ trackContentUsage(contentId)
             │    userCompletionCount++
             │
             └──→ Every completion
                  increments counter
              │
              ▼
    ┌──────────────────────┐
    │ STEP 5: THRESHOLD    │
    │ REACHED (100 users)  │
    └────────┬─────────────┘
             │
             ├──→ checkAndGiveUsageReward()
             │
             ├──→ Create RewardTransaction
             │    - rewardType: "usage_threshold"
             │    - amount: 10 × 150 = 1500
             │
             ├──→ Update sme_wallets
             │    - availableBalance += 1500
             │    - totalEarnings += 1500
             │
             ├──→ Update content
             │    - usageRewardGiven = true
             │    - usageRewardAmount = 1500
             │
             └──→ notifyListeners()
                  SME sees bonus reward!
              │
              ▼
    ┌──────────────────────┐
    │ FINAL WALLET STATE   │
    ├──────────────────────┤
    │ totalEarnings: 2000  │
    │ availableBalance:2000│
    │ totalWithdrawn: 0    │
    └──────────────────────┘
```

---

This visual guide helps understand the system architecture and data flow at a glance.
