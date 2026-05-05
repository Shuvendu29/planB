# Exam Preparation App Development Note

This workspace is for a cross-platform exam preparation application targeting:
- iOS, Android, and Web

Core features:
- Authentication via Mobile OTP, Google, Email/Password, and Apple ID
- User-facing content: Entrance exams, mock tests, current affairs, syllabus, study notes, exam schedules
- Points and recharge system: users earn points and spend them to access tests

Subject Matter Expert (SME) web interface:
- KYC onboarding with Aadhaar details, PAN, bank information, and document upload
- Content creation: entrance tests, mock tests, current affairs, study notes
- Role-restricted access managed by admin

Admin/CMS panel:
- Approve and manage SMEs
- Moderate and control content
- Monitor points, transactions, and user activity

Backend architecture:
- Firebase Auth, Firestore, Storage, Hosting, and potentially Functions
- Role-based data access and security rules

Use this note as the baseline plan for development in this workspace.