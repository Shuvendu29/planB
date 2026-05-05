# UX/UI Design Specification - Exam Prep App (PlanB)

## Design System Overview

### Color Palette

| Role | Primary | Secondary | Accent | Background |
|------|---------|-----------|--------|------------|
| **User** | `#2563EB` (Blue) | `#10B981` (Emerald) | `#F59E0B` (Amber) | `#F8FAFC` |
| **SME** | `#7C3AED` (Violet) | `#8B5CF6` (Purple) | `#F59E0B` (Amber) | `#FAF5FF` |
| **Admin** | `#DC2626` (Red) | `#EF4444` (Rose) | `#F59E0B` (Amber) | `#FEF2F2` |

### Typography

| Style | Size | Weight | Use Case |
|-------|------|--------|----------|
| Headline 1 | 32px | Bold | Main titles |
| Headline 2 | 24px | Bold | Section titles |
| Headline 3 | 20px | Semi-bold | Card titles |
| Subtitle 1 | 16px | Semi-bold | List item titles |
| Subtitle 2 | 14px | Medium | Secondary info |
| Body 1 | 16px | Normal | Main content |
| Body 2 | 14px | Normal | Secondary content |
| Caption | 12px | Normal | Labels, hints |
| Button | 14px | Semi-bold | Button text |

### Spacing System

- **xs**: 4px
- **sm**: 8px
- **md**: 16px
- **lg**: 24px
- **xl**: 32px
- **xxl**: 48px

### Border Radius

- **Small**: 8px (buttons, inputs)
- **Medium**: 12px (cards, containers)
- **Large**: 16px (modals, sheets)
- **Full**: 50% (avatars, badges)

---

## User App (Mobile-First Design)

### Screen Structure

```
┌─────────────────────────────────────────┐
│              Bottom Nav Bar              │
├─────────────────────────────────────────┤
│  🏠 Home  │  📚 Exams  │  📊 Results  │  👤 Profile │
└─────────────────────────────────────────┘
```

### 1. Home Screen

```
┌─────────────────────────────────────────┐
│ 🔔  Exam Prep App              👤 Avatar │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │  ⭐ Your Points: 250        [Top Up] │ │  ← Points Card (Gradient)
│ └─────────────────────────────────────┘ │
│                                         │
│ Quick Actions                           │
│ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐    │
│ │Mock  │ │Current│ │Syllabus│ │Schedule│ │  ← Quick Action Buttons
│ │Tests │ │Affairs│ │        │ │        │ │
│ └──────┘ └──────┘ └──────┘ └──────┘    │
│                                         │
│ Recommended Exams          See All →    │
│ ┌─────────────────────────────────────┐ │
│ │ 📚 JEE Main 2025                    │ │
│ │    90 Q • 180 min • 50 Points       │ │  ← Exam Cards
│ │    [Start Exam]                     │ │
│ └─────────────────────────────────────┘ │
│ ┌─────────────────────────────────────┐ │
│ │ 📚 NEET UG 2025                     │ │
│ │    180 Q • 200 min • 75 Points      │ │
│ │    [Start Exam]                     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Today's Leaderboard          View →     │
│ ┌─────────────────────────────────────┐ │
│ │ 🥇 Rahul S.    -  1250 pts          │ │
│ │ 🥈 Priya M.    -  1180 pts          │ │  ← Mini Leaderboard
│ │ 🥉 Amit K.     -  1100 pts          │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### 2. Exam Listing Screen

```
┌─────────────────────────────────────────┐
│ ←  Browse Exams              🔍 Search  │
├─────────────────────────────────────────┤
│ [All] [JEE] [NEET] [UPSC] [State] [+]   │  ← Filter Chips
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 📚 JEE Advanced 2025         [75★]  │ │
│ │    Physics • Chemistry • Math       │ │
│ │    90 Questions • 180 min           │ │
│ │    ─────────────────────────        │ │
│ │    💰 50 Points    📅 Jan 15, 2025  │ │
│ │    [Take Exam]                      │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 📚 NEET UG 2025              [60★]  │ │
│ │    PCB • 180 Questions • 200 min    │ │
│ │    ─────────────────────────        │ │
│ │    💰 75 Points    📅 Jan 20, 2025  │ │
│ │    [Take Exam]                      │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Showing 12 of 45 exams                  │
└─────────────────────────────────────────┘
```

### 3. Exam Taking Screen

```
┌─────────────────────────────────────────┐
│ ← JEE Main 2025        15/90   ⏱ 145:32 │
├─────────────────────────────────────────┤
│ ████████████░░░░░░░░░░░░░░░░░░░░░░░░░░  │  ← Progress Bar
│                                         │
│ Q15: Which of the following is the      │
│ correct order of ionization energy?     │
│                                         │
│ ○ A) Na < Mg < Al < Si                  │
│ ● B) Na < Mg < Si < Al    ← Selected    │
│ ○ C) Mg < Na < Al < Si                  │
│ ○ D) Al < Si < Mg < Na                  │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 1  2  3  4  5  6  7  8  9  10      │ │
│ │ 11 12 13 14 15 16 17 18 19 20      │ │  ← Question Navigator
│ │ ●  ○  ○  ○  ●  ○  ○  ○  ○  ○       │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ [Previous]                      [Next →]│
│                              [Submit]   │
└─────────────────────────────────────────┘
```

### 4. Results Screen

```
┌─────────────────────────────────────────┐
│ ←  My Results                           │
├─────────────────────────────────────────┤
│ Overall Performance                     │
│ ┌─────────────────────────────────────┐ │
│ │         78%                         │ │  ← Circular Progress
│ │      Correct                        │ │
│ │    70/90 Questions                  │ │
│ │    ⏱ 165 min                       │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Subject-wise Breakdown                  │
│ ┌─────────────────────────────────────┐ │
│ │ Physics    ████████████░░░  85%    │ │
│ │ Chemistry  ██████████░░░░░  70%    │ │  ← Progress Bars
│ │ Math       ████████░░░░░░░  65%    │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Recent Results                          │
│ ┌─────────────────────────────────────┐ │
│ │ JEE Main 2025          78%  ✅     │ │
│ │ Jan 15, 2025           70/90       │ │
│ │ [View Details]  [Review Answers]   │ │
│ └─────────────────────────────────────┘ │
│ ┌─────────────────────────────────────┐ │
│ │ NEET UG 2025           82%  ✅     │ │
│ │ Jan 10, 2025          148/180      │ │
│ │ [View Details]  [Review Answers]   │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### 5. Profile Screen

```
┌─────────────────────────────────────────┐
│              My Profile                 │
├─────────────────────────────────────────┤
│         ┌─────────────┐                 │
│         │   👤 Avatar │                 │  ← Profile Photo
│         │      120px  │                 │
│         └─────────────┘                 │
│         John Doe                        │
│         john.doe@email.com              │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │  Points Balance                     │ │
│ │  💰 250 Points          [Top Up]    │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ My Stats                                │
│ ┌──────────┐ ┌──────────┐ ┌──────────┐ │
│ │ Exams    │ │ Correct  │ │ Streak   │ │
│ │   45     │ │   78%    │ │   12 days│ │
│ └──────────┘ └──────────┘ └──────────┘ │
│                                         │
│ 📋 Transaction History                  │
│ 🔒 Change Password                     │
│ 🔔 Notification Settings               │
│ ❓ Help & Support                       │
│ 🚪 Log Out                             │
└─────────────────────────────────────────┘
```

### 6. Top-Up Screen (Modal)

```
┌─────────────────────────────────────────┐
│              💰 Top Up                  │
├─────────────────────────────────────────┤
│                                         │
│ Select Amount                           │
│ ┌────────┐ ┌────────┐ ┌────────┐       │
│ │  ₹100  │ │  ₹500  │ │ ₹1000  │       │  ← Amount Chips
│ │ +5 pts │ │ +25 pts│ │ +50 pts│       │
│ └────────┘ └────────┘ └────────┘       │
│ ┌──────────────────┐                   │
│ │ Custom: ₹______  │                   │
│ └──────────────────┘                   │
│                                         │
│ First time? Get 5% extra! 🎉           │
│                                         │
│ Payment Method                          │
│ ○ UPI / Google Pay                      │
│ ○ Credit / Debit Card                   │
│ ○ Net Banking                           │
│                                         │
│ [    Pay ₹100 Now    ]                 │  ← Primary Button
│                                         │
└─────────────────────────────────────────┘
```

---

## SME Dashboard (Web-Optimized)

### Layout Structure

```
┌─────────────────────────────────────────────────────────────┐
│  Logo  │  Dashboard  │  My Content  │  Earnings  │  👤 Menu │
├────────┴─────────────┴──────────────┴────────────┴──────────┤
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐                   │
│  │ Total Earnings  │  │ Pending Review  │                   │
│  │   ₹12,450       │  │      3          │                   │
│  └─────────────────┘  └─────────────────┘                   │
│  ┌─────────────────┐  ┌─────────────────┐                   │
│  │ Approved Content│  │ This Month      │                   │
│  │      15         │  │   +₹2,500       │                   │
│  └─────────────────┘  └─────────────────┘                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 1. SME Dashboard Home

```
┌─────────────────────────────────────────────────────────────┐
│ 📊 SME Dashboard                    [Notifications] [Profile]│
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ ┌─────────────────────┐  ┌─────────────────────┐           │
│ │ 💰 Wallet Balance   │  │ 📈 This Month       │           │
│ │   ₹12,450.00        │  │   +₹2,500.00 ↑      │           │
│ │ Available: ₹8,200   │  │ 5 new approvals     │           │
│ │ [Withdraw] [History]│  │                     │           │
│ └─────────────────────┘  └─────────────────────┘           │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Earnings Chart (Last 6 months)                          │ │
│ │                                                         │ │
│ │    █                                                   │ │
│ │    █  █        █                                       │ │
│ │ █  █  █  █  █  █  █                                   │ │
│ │ ────────────────                                      │ │
│ │ Oct  Nov  Dec  Jan  Feb  Mar                          │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ Recent Transactions                          View All →    │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ ✅ Mock Test Approval          +₹500    Jan 15, 2025   │ │
│ │ ✅ Study Notes Approval        +₹100    Jan 12, 2025   │ │
│ │ ✅ Usage Reward (150 users)   +₹1500    Jan 10, 2025   │ │
│ │ ✅ Entrance Exam Approval    +₹1000    Jan 5, 2025    │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ Pending Content (3)                        Review →        │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 📝 Physics Mock Test 2025    [Edit]  [Delete]          │ │
│ │    Status: Under Review • Submitted: Jan 10            │ │
│ └─────────────────────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 📝 Chemistry Notes Chapter 4  [Edit]  [Delete]         │ │
│ │    Status: Under Review • Submitted: Jan 8             │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 2. Content Upload Screen

```
┌─────────────────────────────────────────────────────────────┐
│ ← Upload New Content                                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Content Type                                               │
│ [Exam] [Mock Test] [Study Notes] [Current Affairs]         │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Title *                                                 │ │
│ │ Enter content title...                                  │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Description *                                           │ │
│ │ Describe your content...                                │ │
│ │                                                         │ │
│ │                                                         │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ Category *                                                 │
│ [Select Category ▼]                                        │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Upload Files *                                          │ │
│ │                                                         │ │
│ │    📁 Drag files here or click to browse               │ │
│ │       PDF, DOC, JPG up to 50MB                         │ │
│ │                                                         │ │
│ │ ┌─────────┐ ┌─────────┐ ┌─────────┐                    │ │
│ │ │ file1   │ │ file2   │ │   +     │                    │ │
│ │ │   ✕     │ │   ✕     │ │  Add    │                    │ │
│ │ └─────────┘ └─────────┘ └─────────┘                    │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ Reward Preview                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Upon approval, you'll earn:                            │ │
│ │ • Base reward: ₹100                                    │ │
│ │ • Type bonus: ₹500 (Mock Test)                         │ │
│ │ • Total: ₹600                                          │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ [Cancel]                              [Submit for Review]  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 3. My Content Screen

```
┌─────────────────────────────────────────────────────────────┐
│ My Content                    [Search] [Filter ▼]          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ [All] [Approved] [Pending] [Rejected]                      │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 📚 JEE Physics Mock Test 2025                           │ │
│ │ ────────────────────────────────────────                │ │
│ │ Type: Mock Test    |    Category: Physics               │ │
│ │ Status: ✅ Approved    |    Earned: ₹500                │ │
│ │ Views: 234    |    Completions: 156                     │ │
│ │ Uploaded: Jan 5, 2025   |   Approved: Jan 10, 2025     │ │
│ │ ────────────────────────────────────────                │ │
│ │ [View] [Analytics] [Edit] [Delete]                      │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 📝 Chemistry Chapter 3 Notes                            │ │
│ │ ────────────────────────────────────────                │ │
│ │ Type: Study Notes   |    Category: Chemistry            │ │
│ │ Status: ⏳ Pending   |    Expected: ₹100                │ │
│ │ Uploaded: Jan 15, 2025                                  │ │
│ │ ────────────────────────────────────────                │ │
│ │ [View] [Edit] [Delete]                                  │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 📰 Current Affairs - Jan 2025                           │ │
│ │ ────────────────────────────────────────                │ │
│ │ Type: Current Affairs   |    Category: General          │ │
│ │ Status: ❌ Rejected    |    Reason: Incomplete content  │ │
│ │ Submitted: Jan 12, 2025   |   Rejected: Jan 14, 2025   │ │
│ │ ────────────────────────────────────────                │ │
│ │ [View] [Resubmit]                                       │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ Showing 1-10 of 45 items           [<] 1 2 3 4 5  [>]      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 4. Earnings & Wallet Screen

```
┌─────────────────────────────────────────────────────────────┐
│ My Earnings                        [Export] [Withdraw]      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 💰 Wallet Summary                                       │ │
│ │                                                         │ │
│ │ Total Earned    │ Available    │ Pending    │ Withdrawn│ │
│ │   ₹15,200       │   ₹8,200     │  ₹2,000    │  ₹5,000  │ │
│ │                 │ [Withdraw]   │ (Processing)│          │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ Transaction History                        [Filter ▼]      │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 📅 This Month (March 2025)                             │ │
│ │ ────────────────────────────────────────                │ │
│ │ ✅ Mock Test Approval         +₹500   Mar 15           │ │
│ │ ✅ Usage Reward (200 users)  +₹2000  Mar 10           │ │
│ │ ✅ Study Notes Approval      +₹100   Mar 5            │ │
│ └─────────────────────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 📅 February 2025                                       │ │
│ │ ────────────────────────────────────────                │ │
│ │ 💸 Withdrawal to HDFC          -₹2000  Feb 28          │ │
│ │ ✅ Entrance Exam Approval    +₹1000  Feb 20           │ │
│ │ ✅ Current Affairs Approval   +₹50   Feb 15           │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ Earnings by Content Type                                    │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Mock Tests     ████████████████  ₹8,000 (52%)          │ │
│ │ Entrance Exams ████████          ₹5,000 (33%)          │ │
│ │ Study Notes    ██                ₹1,200 (8%)           │ │
│ │ Current Affairs█                 ₹1,000 (7%)           │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Admin Panel (Web-Optimized)

### Layout Structure

```
┌─────────────────────────────────────────────────────────────┐
│  Logo  │  Dashboard  │  Content  │  SMEs  │  Rewards  │ ⚙️ │
├────────┴─────────────┴────────────┴────────┴────────────┴──┤
│  Sidebar (Collapsible)  │        Main Content Area         │
│                         │                                   │
│  📊 Overview            │                                   │
│  📝 Content             │                                   │
│  👥 SMEs                │                                   │
│  💰 Rewards             │                                   │
│  📈 Analytics           │                                   │
│  ⚙️ Settings            │                                   │
└─────────────────────────────────────────────────────────────┘
```

### 1. Admin Dashboard Home

```
┌─────────────────────────────────────────────────────────────┐
│ 🔴 Admin Dashboard              [🔔 5] [👤 Admin]          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│ │  Users   │ │   SMEs   │ │  Content │ │ Revenue  │       │
│ │  12,450  │ │    156   │ │   890    │ │ ₹45,200  │       │
│ │  +124    │ │   +12    │ │  +45     │ │ +₹5,200  │       │
│ └──────────┘ └──────────┘ └──────────┘ └──────────┘       │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Content Approval Queue (12 pending)                     │ │
│ │ ────────────────────────────────────────                │ │
│ │ [Review All]                                            │ │
│ │                                                         │ │
│ │ 📝 Physics Mock Test - SME: Rahul S.    [Approve] [Reject]│
│ │    Submitted: 2 hours ago                               │ │
│ │                                                         │ │
│ │ 📝 Chemistry Notes Ch.5 - SME: Priya M.  [Approve] [Reject]│
│ │    Submitted: 5 hours ago                               │ │
│ │                                                         │ │
│ │ 📝 Current Affairs Jan - SME: Amit K.   [Approve] [Reject]│
│ │    Submitted: 1 day ago                                 │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌────────────────────────┐  ┌────────────────────────┐     │
│ │ Top Performing Content │  │ SME Leaderboard        │     │
│ │ ─────────────────────  │  │ ─────────────────────  │     │
│ │ 1. JEE Mock 2025       │  │ 1. Rahul S.  ₹12,450  │     │
│ │    1,234 completions   │  │ 2. Priya M.  ₹10,200  │     │
│ │ 2. NEET 2025           │  │ 3. Amit K.   ₹8,900   │     │
│ │    987 completions     │  │                        │     │
│ └────────────────────────┘  └────────────────────────┘     │
│                                                             │
│ Recent System Activity                                      │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 👤 User john@email.com purchased 100 points             │ │
│ │ 👤 SME Rahul S. submitted new content                   │ │
│ │ ⚠️ 3 content items flagged for review                   │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 2. Content Management Screen

```
┌─────────────────────────────────────────────────────────────┐
│ Content Management              [Search] [Filter] [Export] │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ [All] [Pending] [Approved] [Rejected] [Flagged]            │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ ☑ │ Title          │ Type      │ SME      │ Status    │ │
│ │───│────────────────│───────────│──────────│───────────│ │
│ │ ☑ │ Physics Mock   │ Mock Test │ Rahul S. │ ⏳ Pending│ │
│ │ ☐ │ Chemistry Notes│ Study     │ Priya M. │ ✅ Approved│ │
│ │ ☐ │ Current Affairs│ Current   │ Amit K.  │ ❌ Rejected│ │
│ │ ☐ │ Math Practice  │ Exam      │ John D.  │ ⚠️ Flagged │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ Bulk Actions: [Approve Selected] [Reject Selected] [Delete]│
│                                                             │
│ ─────────────────────────────────────────────────────────── │
│                                                             │
│ Content Details: Physics Mock Test 2025                    │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Title: Physics Mock Test 2025                           │ │
│ │ Type: Mock Test    Category: Physics                    │ │
│ │ SME: Rahul S. (rahul@email.com)                         │ │
│ │ Submitted: Jan 15, 2025 10:30 AM                        │ │
│ │ ────────────────────────────────────────                │ │
│ │ Description:                                             │ │
│ │ Complete physics mock test covering all chapters...     │ │
│ │ ────────────────────────────────────────                │ │
│ │ Files: physics_mock_2025.pdf (2.5MB)                    │ │
│ │ ────────────────────────────────────────                │ │
│ │ Stats: 0 views • 0 completions • 0 flags                │ │
│ │ ────────────────────────────────────────                │ │
│ │ [Reject]    [Request Changes]    [Approve]              │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 3. SME Management Screen

```
┌─────────────────────────────────────────────────────────────┐
│ SME Management              [Search] [Filter] [Add New]    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ [All] [Active] [Pending KYC] [Suspended]                   │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ ☑ │ Name        │ Email        │ Content │ Earnings   │ │
│ │───│─────────────│──────────────│─────────│────────────│ │
│ │ ☑ │ Rahul S.    │ rahul@...    │   45    │ ₹12,450    │ │
│ │ ☐ │ Priya M.    │ priya@...    │   32    │ ₹10,200    │ │
│ │ ☐ │ Amit K.     │ amit@...     │   28    │ ₹8,900     │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ─────────────────────────────────────────────────────────── │
│                                                             │
│ SME Profile: Rahul S.                                       │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 👤 Profile  │ 📝 Content  │ 💰 Wallet  │ ⚠️ History  │ │
│ │ ────────────────────────────────────────                │ │
│ │ Name: Rahul Sharma                                       │ │
│ │ Email: rahul.sharma@email.com                            │ │
│ │ Phone: +91 98765 43210                                   │ │
│ │ ────────────────────────────────────────                │ │
│ │ KYC Status: ✅ Verified                                  │ │
│ │ Aadhaar: ****1234                                        │ │
│ │ PAN: ****5678                                            │ │
│ │ Bank: HDFC Bank ****7890                                 │ │
│ │ ────────────────────────────────────────                │ │
│ │ Total Content: 45                                        │ │
│ │ Approved: 40  |  Pending: 3  |  Rejected: 2             │ │
│ │ ────────────────────────────────────────                │ │
│ │ Total Earnings: ₹12,450                                  │ │
│ │ Withdrawn: ₹5,000  |  Available: ₹7,450                 │ │
│ │ ────────────────────────────────────────                │ │
│ │ [Suspend SME] [View Full Profile] [Contact]             │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 4. Reward Configuration Screen

```
┌─────────────────────────────────────────────────────────────┐
│ Reward Configuration                                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Global Settings                                          │ │
│ │ ────────────────────────────────────────                │ │
│ │ Rewards Enabled:  [Toggle: ON]                          │ │
│ │ Last Updated: Jan 15, 2025 by Admin                     │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ Approval Rewards (per content type)                        │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Content Type          │ Amount (₹)  │ Active            │ │
│ │ ──────────────────────┼─────────────┼───────────────────│ │
│ │ Mock Test             │   500       │ [Toggle]          │ │
│ │ Entrance Exam         │  1000       │ [Toggle]          │ │
│ │ Study Notes           │   100       │ [Toggle]          │ │
│ │ Current Affairs       │    50       │ [Toggle]          │ │
│ │ [Add New Type]                                           │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ Usage-Based Rewards                                         │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Reward per user completion:      ₹ 10                   │ │
│ │ Minimum users for reward:           100                 │ │
│ │                                                         │ │
│ │ Example: If 200 users complete your content:           │ │
│ │ → You earn: ₹10 × 200 = ₹2,000                         │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ [Reset to Defaults]                    [Save Configuration]│
│                                                             │
│ ─────────────────────────────────────────────────────────── │
│                                                             │
│ Reward Distribution Summary (This Month)                   │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Total Distributed: ₹45,200                              │ │
│ │ ────────────────────────────────────────                │ │
│ │ Approval Rewards:   ₹25,000 (55%)                       │ │
│ │ Usage Rewards:      ₹15,200 (34%)                       │ │
│ │ Bonuses:            ₹5,000 (11%)                        │ │
│ │ ────────────────────────────────────────                │ │
│ │ Top SME: Rahul S. - ₹2,500                              │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 5. Analytics Screen

```
┌─────────────────────────────────────────────────────────────┐
│ Analytics & Reports                    [Date Range] [Export]│
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ User Activity (Last 30 days)                            │ │
│ │                                                         │ │
│ │    █                                                   │ │
│ │    █  █  █                                            │ │
│ │ █  █  █  █  █  █  █  █  █  █                          │ │
│ │ ─────────────────────────────────────                  │ │
│ │ 1   5  10  15  20  25  30                             │ │
│ │                                                         │ │
│ │ Daily Active Users: 1,234 avg                          │ │
│ │ Total Exam Attempts: 45,678                            │ │
│ │ Average Score: 72%                                     │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ ┌─────────────────────┐  ┌─────────────────────┐           │
│ │ Top Exams           │  │ User Demographics   │           │
│ │ ─────────────────── │  │ ─────────────────── │           │
│ │ 1. JEE Main  45%   │  │ 18-25: 45%          │           │
│ │ 2. NEET UG   30%   │  │ 26-35: 35%          │           │
│ │ 3. UPSC      15%   │  │ 36+: 20%            │           │
│ │ 4. State    10%    │  │                      │           │
│ └─────────────────────┘  └─────────────────────┘           │
│                                                             │
│ Revenue Analytics                                           │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Point Purchases: ₹35,000 (70%)                         │ │
│ │ Premium Subs:  ₹15,000 (30%)                           │ │
│ │ ────────────────────────────────────────                │ │
│ │ Total Revenue: ₹50,000                                 │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Component Library Summary

### Shared Components

| Component | Description | Usage |
|-----------|-------------|-------|
| `StatCard` | Display metrics with icon | All dashboards |
| `SectionHeader` | Title + action button | List sections |
| `EmptyState` | No data placeholder | Empty lists |
| `AppLoader` | Loading spinner | Async operations |
| `StatusBadge` | Status indicator | Content status |
| `PointsCard` | Points display with top-up | User home |
| `ContentListTile` | List item card | Content lists |
| `QuickActionButton` | Icon + label button | Home screen |

### Navigation Patterns

| Role | Primary Nav | Secondary |
|------|-------------|-----------|
| User | Bottom Tab Bar | Stack navigation |
| SME | Top Tab Bar | Drawer for settings |
| Admin | Left Sidebar | Top header bar |

### Interaction Patterns

- **Pull to refresh**: List screens
- **Swipe actions**: List items (delete, edit)
- **Modal sheets**: Forms, filters
- **Snackbar notifications**: Actions feedback
- **Confirmation dialogs**: Destructive actions

---

## Implementation Notes

1. **Responsive Design**: Use `LayoutBuilder` for adaptive layouts
2. **Theme Switching**: Implement `ThemeProvider` for light/dark modes
3. **Animations**: Use `AnimatedContainer` and `Hero` for smooth transitions
4. **Accessibility**: Ensure semantic labels and sufficient contrast
5. **Performance**: Use `ListView.builder` for long lists, lazy loading images