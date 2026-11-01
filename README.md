# CampusSathi

College companion app: fee status and payment, live attendance, performance insights, notes and assignments, and fair event judging.

## Current status

Phase 0 (landing pages), Phase 1 (authentication) and Phase 2 (teacher side), Phase 3 (student side) and Phase 4 (attendance and fees) Phase 5 (events and fair judging) and Phase 6 (AI insights) and Phase 7 (mobile app and deployment) are written.

- Registration is checked against a `college_records` table: ID, role, full name and college email must all match
- Passwords are hashed with BCrypt; login returns a JWT (valid 2 hours)
- Role-based access: `/api/student/**`, `/api/teacher/**`, `/api/organiser/**`
- 5 wrong passwords lock an ID for 15 minutes
- Placeholder dashboards for each role (they check the login and show the user's name)
- Uses a file-based H2 database in `./data`, so nothing extra to install

**Phase 2 (teacher side)**

- Classes: a teacher creates classes (code, name, section) and adds students by college ID. Only people marked as active students in `college_records` can be added.
- Tests, quizzes, assignments and semester exams, each with maximum marks and a date (held on / due on)
- Marks entry per assessment: checked against the maximum, only for enrolled students, all-or-nothing save
- Notes: upload PDF, Word, PowerPoint, Excel, CSV, text or image files (10 MB each); saved in `./uploads`, downloaded only through the API
- Weak-student report: students whose overall score is below a threshold (default 40%)
- Teachers only ever see their own classes (another teacher's class returns "not found")
- Teacher dashboard page (`teacher-dashboard.html`) with all of the above

API reference: `docs/phase2-teacher-api.md`

**Phase 3 (student side)**

- The student dashboard (`student-dashboard.html`) shows what teachers post, read-only: overview, marks per class, assignments with status (upcoming / past due / graded), and notes to download
- "Needs attention" flags graded items below 40%
- A student sees only classes they are enrolled in, and only their own marks

API reference: `docs/phase3-student-api.md`

**Phase 4 (attendance and fees)**

- Attendance: the teacher opens a time window at the classroom's location; students mark themselves present once, from inside the radius. The server checks time, enrolment, distance and once-only. Teachers can override and see a per-student percentage (75% needed)
- Fees: students see invoices with items, paid and balance, and pay in full or in parts. Payments run in **test mode** (no real money) until a real payment gateway is added; demo invoices are created for the demo students
- Limits: location comes from the phone and can be faked, and there is no face check yet; there is no screen for creating real fee structures yet

Details: `docs/phase4-attendance-fees.md`

**Phase 5 (events and fair judging)**

- Organisers create events. A competition needs judging criteria (name, max score, weight; weights add up to 100) and at least 2 judges. Publishing **freezes** the criteria and the judge list
- Students see events as happening now / upcoming / past, register alone or in a team, and see how they will be judged before they enter
- Judges (teachers assigned by the organiser) score entries in the new **Judging panel** (`judge.html`). They see an entry number, project title and summary, not names, in an order that differs per judge, and never see other judges' scores. A judge must score every entry on every criterion before submitting, and cannot edit after that
- The organiser sees no scores until all judges have submitted and the results are locked. After the lock nothing can change; students see the ranking and a full breakdown of their own score, and anyone can press **Verify** to check a saved fingerprint of all scores
- Limits: the fingerprint detects silent changes only if someone keeps a copy of it outside the database; judges are teachers only (no outside judges yet); no push notifications yet, students see an Events tab with a count

Details: `docs/phase5-events.md`

**Phase 6 (performance insights and AI study suggestions)**

- Teachers can tag a test or assignment with a **topic**. Marks are grouped by topic (an untagged test counts as its own topic)
- Students get a **My progress** tab: weak topics (below 50%), strong topics (75% and above), trend (improving, dropping, steady), attendance, and a written study plan
- The plan is written by **Claude** when `ANTHROPIC_API_KEY` is set. Without a key, or if the AI call fails, students get simple built-in suggestions, so the page always works
- Only topic scores, class names and attendance percentages are sent to the AI, never a name, ID or email. Suggestions are saved and only rewritten when the marks change
- Teachers get an **Insights** tab: bright students, students who need help, and the weak and strong topics of the class, with adjustable thresholds
- Limits: the AI call could not be tested here, topic analysis is only as good as the topics teachers enter, and teacher-side AI summaries are not built yet

Details: `docs/phase6-ai-insights.md`

**Phase 7 (mobile app, deployment and polish)**

- The site installs on a phone like an app (PWA): icon, full-screen mode, install prompt, offline page. Phone screens got safe-area, touch-size and scrolling fixes
- `mobile/` holds the Capacitor setup for an Android `.apk`; `Dockerfile` and `deploy/` run MySQL + the app + automatic https on one server
- `scripts/smoke-test.sh https://your-domain` checks a running server; `MobileAssetsTest` checks the install files and headers
- Limits: the Android build and the Docker setup were written but not run here; phones need **https** for location; there is still no live camera check for attendance and no push notifications

Details and the device checklist: `docs/phase7-mobile.md`

## Run it

You need JDK 17 or newer and Maven.

```
mvn test
mvn spring-boot:run
```

Open http://localhost:8080 and register with a demo record:

| Role | ID | Full name | Email |
|---|---|---|---|
| Student | 2026CS0142 | Rahul Sharma | rahul.sharma@college.edu |
| Teacher | FAC-0231 | Dr. Neha Gupta | neha.gupta@college.edu |
| Organiser | ORG-014 | Kavya Tiwari | kavya.tiwari@college.edu |

Register the teacher, then log in as Teacher to try Phase 2; add the student IDs above to a class. (More are in `DemoDataSeeder.java`.) Before any real use: set `app.seed-demo-data=false`,
set the `JWT_SECRET` environment variable, set `ANTHROPIC_API_KEY` if you want AI-written study suggestions, set `UPLOAD_DIR` to a folder that is backed up, and load the college's real records.

## Folder layout

```
CampusSathi/
  pom.xml
  docs/                              design notes and roadmap (add here)
  src/main/java/com/campussathi/     Java backend
  src/main/resources/
    application.properties
    static/                          frontend
      index.html  login.html  register.html
      css/style.css
      js/auth.js  js/dashboard.js  js/teacher.js  js/student.js
      js/organiser.js  js/judge.js  js/events-common.js  js/pwa.js
      manifest.json  sw.js  offline.html  images/icons/
      (root) Dockerfile  deploy/  mobile/  scripts/  tools/make_icons.py
      (java) ai/AiClient, ClaudeAiClient; service/InsightsService, AdviceService
      judge.html
      student-dashboard.html  teacher-dashboard.html  organiser-dashboard.html
      images/campus-bg.svg
  src/test/java/com/campussathi/     tests (Auth, Teacher, Student, Attendance, Fee and Event flow tests)
  uploads/                           uploaded notes (created at run time, not in git)
```

## Next

All seven roadmap phases are written. Still open: judge comments, outside judges, push notifications, office / admin screens for fee structures, a real payment gateway, a face / liveness check for attendance, and a screen for the college office to load records.
