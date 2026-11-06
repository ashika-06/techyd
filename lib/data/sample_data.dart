import '../models/event.dart';
import '../models/report.dart';

/// Areas used for filtering and for the "submit an event" form.
const List<String> kAreas = [
  'Gachibowli',
  'HITEC City',
  'Madhapur',
  'Kondapur',
  'Kukatpally',
  'Secunderabad',
  'Online',
];

// All dates are relative to "today" so the demo always looks fresh.
DateTime _d(int days, int hour, [int minute = 0]) {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day + days, hour, minute);
}

/// SAMPLE DATA for the demo. Organisers are fictional; venues are real
/// Hyderabad locations used only to make the demo feel local.
List<TechEvent> sampleEvents() => [
      TechEvent(
        id: 'ev01',
        title: 'AI Builders Meetup: Shipping RAG to Production',
        organizer: 'AI Builders HYD',
        category: EventCategory.aiMl,
        mode: EventMode.offline,
        venue: 'T-Works, Raidurg',
        area: 'HITEC City',
        start: _d(2, 18),
        end: _d(2, 20, 30),
        price: 0,
        capacity: 120,
        registered: 96,
        description:
            'Practitioners walk through what actually breaks when a retrieval-augmented '
            'generation prototype meets real users: chunking, evals, latency and cost. '
            'Three short talks, one live teardown and open networking.',
        tags: ['RAG', 'LLMs', 'Evals', 'Networking'],
        agenda: [
          AgendaItem('6:00 PM', 'Doors open & coffee'),
          AgendaItem('6:30 PM', 'Talk: Chunking strategies that survive production'),
          AgendaItem('7:15 PM', 'Live teardown: debugging a failing RAG pipeline'),
          AgendaItem('8:00 PM', 'Open networking'),
        ],
      ),
      TechEvent(
        id: 'ev02',
        title: 'Cloud Native Night',
        organizer: 'CloudOps Hyderabad',
        category: EventCategory.cloud,
        mode: EventMode.hybrid,
        venue: 'Cyber Towers, Madhapur',
        area: 'Madhapur',
        start: _d(4, 18, 30),
        end: _d(4, 21),
        price: 0,
        capacity: 150,
        registered: 61,
        description:
            'An evening on containers, Kubernetes and platform engineering. Attend in '
            'person or stream live. Lightning talks from local engineers followed by a Q&A panel.',
        tags: ['Kubernetes', 'DevOps', 'Platform'],
        agenda: [
          AgendaItem('6:30 PM', 'Welcome'),
          AgendaItem('6:45 PM', 'Lightning talks (5 x 10 min)'),
          AgendaItem('7:45 PM', 'Panel: Running platforms at scale'),
        ],
      ),
      TechEvent(
        id: 'ev03',
        title: 'Flutter Forward Hyderabad',
        organizer: 'FlutterHyd Community',
        category: EventCategory.webMobile,
        mode: EventMode.offline,
        venue: 'IIIT Hyderabad, Gachibowli',
        area: 'Gachibowli',
        start: _d(5, 10),
        end: _d(5, 16),
        price: 199,
        capacity: 250,
        registered: 180,
        description:
            'A full day of Flutter: state management patterns, responsive web, animations '
            'and shipping to the stores. Includes lunch and a hands-on build session.',
        tags: ['Flutter', 'Dart', 'Mobile', 'Web'],
        agenda: [
          AgendaItem('10:00 AM', 'Keynote: Flutter beyond mobile'),
          AgendaItem('11:00 AM', 'State management showdown'),
          AgendaItem('1:00 PM', 'Lunch'),
          AgendaItem('2:00 PM', 'Hands-on: build a responsive dashboard'),
        ],
      ),
      TechEvent(
        id: 'ev04',
        title: 'Startup Saturday: Pitch & Pour',
        organizer: 'Founders Circle HYD',
        category: EventCategory.startup,
        mode: EventMode.offline,
        venue: 'Co-working space, Kondapur',
        area: 'Kondapur',
        start: _d(6, 16),
        end: _d(6, 19),
        price: 299,
        capacity: 80,
        registered: 77,
        description:
            'Early-stage founders pitch for 3 minutes each to a panel of operators and '
            'angels. Stay for feedback, coffee and a founder-only mixer.',
        tags: ['Pitching', 'Founders', 'Fundraising'],
        agenda: [
          AgendaItem('4:00 PM', 'Check-in'),
          AgendaItem('4:30 PM', 'Pitch round'),
          AgendaItem('6:00 PM', 'Panel feedback & mixer'),
        ],
      ),
      TechEvent(
        id: 'ev05',
        title: 'LLM Agents Workshop (Hands-on)',
        organizer: 'AI Builders HYD',
        category: EventCategory.workshop,
        mode: EventMode.online,
        venue: 'Live on Google Meet',
        area: 'Online',
        start: _d(7, 19),
        end: _d(7, 21),
        price: 0,
        capacity: 500,
        registered: 340,
        description:
            'Build a tool-using agent from scratch in two hours. Bring a laptop with '
            'Python installed; starter code is shared before the session.',
        tags: ['Agents', 'Python', 'Tool use'],
        agenda: [
          AgendaItem('7:00 PM', 'Concepts: planning, tools, memory'),
          AgendaItem('7:30 PM', 'Live coding'),
          AgendaItem('8:30 PM', 'Debug clinic'),
        ],
      ),
      TechEvent(
        id: 'ev06',
        title: 'HYD Build Sprint: 24-hour Hackathon',
        organizer: 'HydDevs',
        category: EventCategory.hackathon,
        mode: EventMode.offline,
        venue: 'T-Hub 2.0, Raidurg',
        area: 'HITEC City',
        start: _d(9, 9),
        end: _d(10, 9),
        price: 0,
        capacity: 300,
        registered: 214,
        description:
            'Teams of up to four build a working prototype in 24 hours around a '
            'city-scale problem statement. Mentors on the floor, food all night, demos at sunrise.',
        tags: ['Hackathon', 'Teams', 'Prizes', 'Mentors'],
        agenda: [
          AgendaItem('9:00 AM', 'Kick-off & problem statements'),
          AgendaItem('12:00 PM', 'Hacking begins'),
          AgendaItem('Next day, 6:00 AM', 'Demos'),
          AgendaItem('Next day, 8:00 AM', 'Winners announced'),
        ],
      ),
      TechEvent(
        id: 'ev07',
        title: 'Frontend Performance Clinic',
        organizer: 'WebCraft HYD',
        category: EventCategory.workshop,
        mode: EventMode.offline,
        venue: 'HICC, Madhapur',
        area: 'Madhapur',
        start: _d(12, 10),
        end: _d(12, 13),
        price: 499,
        capacity: 60,
        registered: 22,
        description:
            'Bring a slow site, leave with a fast one. Profile, diagnose and fix real '
            'performance problems with guidance from engineers who do this daily.',
        tags: ['Web perf', 'Lighthouse', 'JavaScript'],
        agenda: [
          AgendaItem('10:00 AM', 'Profiling basics'),
          AgendaItem('11:00 AM', 'Fix-it lab'),
          AgendaItem('12:15 PM', 'Before / after showcase'),
        ],
      ),
      TechEvent(
        id: 'ev08',
        title: 'Data Engineering Day',
        organizer: 'DataFlow Guild',
        category: EventCategory.cloud,
        mode: EventMode.hybrid,
        venue: 'Raheja Mindspace, Madhapur',
        area: 'Madhapur',
        start: _d(14, 9, 30),
        end: _d(14, 17),
        price: 799,
        capacity: 200,
        registered: 90,
        description:
            'Pipelines, lakehouses and orchestration in practice. Case studies from '
            'teams moving from batch to streaming, plus a data-quality workshop.',
        tags: ['Data', 'Spark', 'Streaming', 'Lakehouse'],
        agenda: [
          AgendaItem('9:30 AM', 'Keynote'),
          AgendaItem('11:00 AM', 'Case studies'),
          AgendaItem('2:00 PM', 'Workshop: data quality in CI'),
        ],
      ),
      TechEvent(
        id: 'ev09',
        title: 'Campus Hack Night: Beginners Edition',
        organizer: 'HydDevs',
        category: EventCategory.hackathon,
        mode: EventMode.offline,
        venue: 'JNTU Hyderabad, Kukatpally',
        area: 'Kukatpally',
        start: _d(16, 17),
        end: _d(16, 23),
        price: 0,
        capacity: 180,
        registered: 120,
        description:
            'A friendly first hackathon for students: six hours, zero pressure. '
            'Learn git, ship a small project and meet people building things.',
        tags: ['Students', 'Beginner', 'Git'],
        agenda: [
          AgendaItem('5:00 PM', 'Intro to git & GitHub'),
          AgendaItem('6:00 PM', 'Build time'),
          AgendaItem('10:00 PM', 'Show & tell'),
        ],
      ),
      TechEvent(
        id: 'ev10',
        title: 'Founders Fireside: Funding in 2027',
        organizer: 'Founders Circle HYD',
        category: EventCategory.startup,
        mode: EventMode.offline,
        venue: 'T-Hub 2.0, Raidurg',
        area: 'HITEC City',
        start: _d(18, 17, 30),
        end: _d(18, 19, 30),
        price: 0,
        capacity: 100,
        registered: 54,
        description:
            'A candid conversation with founders and investors about what early-stage '
            'funding looks like right now, followed by open Q&A.',
        tags: ['Funding', 'VC', 'Founders'],
        agenda: [
          AgendaItem('5:30 PM', 'Fireside chat'),
          AgendaItem('6:30 PM', 'Audience Q&A'),
        ],
      ),
      TechEvent(
        id: 'ev11',
        title: 'Open Source Contributors Sprint',
        organizer: 'OSS Hyderabad',
        category: EventCategory.workshop,
        mode: EventMode.offline,
        venue: 'Co-working space, Gachibowli',
        area: 'Gachibowli',
        start: _d(21, 10),
        end: _d(21, 17),
        price: 0,
        capacity: 70,
        registered: 31,
        description:
            'Pick a good-first-issue, pair with a maintainer and open your first '
            'pull request by the end of the day.',
        tags: ['Open source', 'GitHub', 'Mentorship'],
        agenda: [
          AgendaItem('10:00 AM', 'How to find your first issue'),
          AgendaItem('11:00 AM', 'Pairing sprint'),
          AgendaItem('4:00 PM', 'PR show-and-tell'),
        ],
      ),
      TechEvent(
        id: 'ev12',
        title: 'MLOps in Practice',
        organizer: 'DataFlow Guild',
        category: EventCategory.aiMl,
        mode: EventMode.hybrid,
        venue: 'Community hub, Secunderabad',
        area: 'Secunderabad',
        start: _d(25, 15),
        end: _d(25, 18),
        price: 249,
        capacity: 90,
        registered: 12,
        description:
            'Take a model from notebook to monitored service. Versioning, CI for ML, '
            'drift detection and what to alert on.',
        tags: ['MLOps', 'Monitoring', 'CI/CD'],
        agenda: [
          AgendaItem('3:00 PM', 'From notebook to service'),
          AgendaItem('4:15 PM', 'Monitoring & drift'),
          AgendaItem('5:15 PM', 'Q&A'),
        ],
      ),
      TechEvent(
        id: 'ev13',
        title: 'Cybersecurity CTF Weekend',
        organizer: 'SecOps Society HYD',
        category: EventCategory.hackathon,
        mode: EventMode.online,
        venue: 'Online platform',
        area: 'Online',
        start: _d(30, 10),
        end: _d(31, 18),
        price: 0,
        capacity: 600,
        registered: 410,
        description:
            'A 32-hour capture-the-flag with web, crypto, forensics and reverse '
            'engineering challenges for beginners through advanced teams.',
        tags: ['CTF', 'Security', 'Teams'],
        agenda: [
          AgendaItem('10:00 AM', 'Challenges go live'),
          AgendaItem('Day 2, 6:00 PM', 'Scoreboard freezes'),
        ],
      ),
      TechEvent(
        id: 'ev14',
        title: 'UX x Dev: Design Systems Meetup',
        organizer: 'WebCraft HYD',
        category: EventCategory.webMobile,
        mode: EventMode.offline,
        venue: 'Co-working space, Kondapur',
        area: 'Kondapur',
        start: _d(35, 18),
        end: _d(35, 20, 30),
        price: 0,
        capacity: 90,
        registered: 18,
        description:
            'Designers and developers compare notes on building and maintaining '
            'design systems that teams actually use.',
        tags: ['Design systems', 'UX', 'Components'],
        agenda: [
          AgendaItem('6:00 PM', 'Talk: tokens to components'),
          AgendaItem('7:00 PM', 'Roundtable'),
        ],
      ),
    ];

/// SAMPLE recaps of past events.
List<EventReport> sampleReports() => [
      EventReport(
        id: 'rp01',
        eventTitle: 'HYD Build Sprint v3',
        category: EventCategory.hackathon,
        date: _d(-6, 9),
        venue: 'T-Hub 2.0, Raidurg',
        attendees: 280,
        speakers: 9,
        hours: 24,
        headline: '280 builders, 61 prototypes, one very sleepless weekend',
        summary:
            'Teams spent 24 hours turning city problems into working demos. Transport '
            'and water-usage tools dominated the final round.',
        highlights: [
          '61 teams submitted a working prototype',
          'Mentors from 14 local companies on the floor',
          'A student team won with a bus-crowding predictor',
        ],
        takeaways: [
          'Scope small: winning demos did one thing well',
          'Teams with a designer shipped noticeably cleaner demos',
          'Mentor office-hours were the most requested feature',
        ],
        winners: [
          '1st: BusSense - crowd prediction for city buses',
          '2nd: WaterWise - household usage insights',
          '3rd: LocalLingo - multilingual civic help bot',
        ],
      ),
      EventReport(
        id: 'rp02',
        eventTitle: 'GenAI Day Hyderabad',
        category: EventCategory.aiMl,
        date: _d(-11, 10),
        venue: 'HICC, Madhapur',
        attendees: 540,
        speakers: 16,
        hours: 8,
        headline: 'From demos to deployments: GenAI grows up',
        summary:
            'A packed hall heard teams describe what it takes to run LLM features in '
            'production. Evaluation and cost control were the recurring themes.',
        highlights: [
          'Live demo of an evaluation harness catching regressions',
          'Panel on build-vs-buy for model hosting',
          'Lightning round: 12 startups in 12 minutes',
        ],
        takeaways: [
          'Write evals before you write prompts',
          'Latency budgets matter more than model size for most apps',
          'Human-in-the-loop review is still the safest default',
        ],
      ),
      EventReport(
        id: 'rp03',
        eventTitle: 'Women in Tech Summit',
        category: EventCategory.startup,
        date: _d(-17, 10),
        venue: 'Raheja Mindspace, Madhapur',
        attendees: 420,
        speakers: 12,
        hours: 7,
        headline: 'A full house for careers, code and community',
        summary:
            'Talks and workshops on leadership, engineering growth and founding. '
            'Mentor speed-dating was the most talked-about session.',
        highlights: [
          'Mentor speed-dating matched 90+ pairs',
          'Workshop on negotiating offers sold out in a day',
          'Closing panel on building inclusive teams',
        ],
        takeaways: [
          'Sponsorship, not just mentorship, changes careers',
          'Communities scale when the format is repeatable',
          'Hybrid access increased first-time attendance',
        ],
      ),
      EventReport(
        id: 'rp04',
        eventTitle: 'Cloud Native Weekend',
        category: EventCategory.cloud,
        date: _d(-24, 10),
        venue: 'Cyber Towers, Madhapur',
        attendees: 230,
        speakers: 8,
        hours: 9,
        headline: 'Kubernetes without the headaches',
        summary:
            'Two days of labs on deployments, observability and cost. Attendees left '
            'with a reference cluster setup they could reuse.',
        highlights: [
          'Hands-on lab: zero-downtime deployments',
          'Observability stack walkthrough',
          'Cost-cutting case study saved 38% for a mid-size team',
        ],
        takeaways: [
          'Standardise before you scale',
          'Dashboards are only useful with owners',
          'Right-size requests early',
        ],
      ),
      EventReport(
        id: 'rp05',
        eventTitle: 'Flutter Study Jam',
        category: EventCategory.workshop,
        date: _d(-31, 11),
        venue: 'IIIT Hyderabad, Gachibowli',
        attendees: 150,
        speakers: 4,
        hours: 5,
        headline: 'First Flutter app live in five hours',
        summary:
            'Beginners built and ran a complete app by the end of the session. '
            'Responsive layout and Provider were the favourite topics.',
        highlights: [
          'Every attendee shipped a running app',
          'Responsive layout mini-lab',
          'State management crash course',
        ],
        takeaways: [
          'Start from widgets, not from architecture',
          'Hot reload is the best teacher',
          'Share finished apps early for feedback',
        ],
      ),
      EventReport(
        id: 'rp06',
        eventTitle: 'Startup Demo Day',
        category: EventCategory.startup,
        date: _d(-40, 16),
        venue: 'T-Hub 2.0, Raidurg',
        attendees: 310,
        speakers: 15,
        hours: 4,
        headline: '15 startups, 4 hours, a lot of follow-up emails',
        summary:
            'Founders demoed to a room of customers and investors. The strongest '
            'pitches led with a concrete customer problem.',
        highlights: [
          'Fifteen live product demos',
          'Investor feedback round after each pitch',
          'Pilot deals started on the spot',
        ],
        takeaways: [
          'Lead with the problem, not the tech',
          'Demo the real product, not slides',
          'Ask for a specific next step',
        ],
        winners: ['Audience favourite: a logistics tracker for small shops'],
      ),
    ];
