import '../../../common/utils/json.dart';

/// Every word, number, link and image reference on the page.
///
/// **This is the one place to change the app.** The demo app is an invented
/// habit coach called Ember. Change `site` for the name, tagline and store
/// links; change the rest section by section. The shape of each section is
/// documented by its mapper in `lib/domain/<feature>/mappers/`.
///
/// The four phone screens (`_todayScreen`, `_progressScreen`, `_calendarScreen`
/// and `_settingsScreen`) and `_goalsScreen` are drawn live from these values
/// and reused by the hero, the features and the gallery.
const Map<String, JsonMap> appContentJson = <String, JsonMap>{
  'site': _site,
  'hero': _hero,
  'trust': _trust,
  'features': _features,
  'howItWorks': _howItWorks,
  'gallery': _gallery,
  'stats': _stats,
  'reviews': _reviews,
  'pricing': _pricing,
  'faq': _faq,
  'download': _download,
  'footer': _footer,
};

const JsonMap _site = <String, Object?>{
  'brandName': 'Ember',
  'brandIcon': 'fire',
  'tagline': 'Build habits that stick, one small win at a time.',
  'navLinks': <Object?>[
    <String, Object?>{'label': 'Features', 'href': '#features'},
    <String, Object?>{'label': 'How it works', 'href': '#how-it-works'},
    <String, Object?>{'label': 'Screens', 'href': '#gallery'},
    <String, Object?>{'label': 'Reviews', 'href': '#reviews'},
    <String, Object?>{'label': 'Pricing', 'href': '#pricing'},
    <String, Object?>{'label': 'FAQ', 'href': '#faq'},
  ],
  'cta': <String, Object?>{'label': 'Get the app', 'href': '#download'},
  'appStore': <String, Object?>{
    'caption': 'Download on the',
    'label': 'App Store',
    'icon': 'apple',
    'href': 'https://ember.example/get/ios',
  },
  'googlePlay': <String, Object?>{
    'caption': 'Get it on',
    'label': 'Google Play',
    'icon': 'play',
    'href': 'https://ember.example/get/android',
  },
};

const JsonMap _hero = <String, Object?>{
  'badge': 'New: Streak Freeze is here',
  'headline': 'Small habits.\nBig days.',
  'subcopy':
      'Ember is the friendly habit coach that lives in your pocket. Check in '
      'once a day, watch your streak grow and let gentle reminders do the '
      'nagging for you.',
  'secondaryCta': <String, Object?>{
    'label': 'See how it works',
    'href': '#how-it-works',
  },
  'rating': 4.8,
  'ratingText': '4.8 · 120K ratings',
  'ratingLabel': 'Rated 4.8 out of 5 from 120,000 ratings',
  'avatars': <Object?>[
    'assets/images/avatar-priya.jpg',
    'assets/images/avatar-mei.jpg',
    'assets/images/avatar-tunde.jpg',
    'assets/images/avatar-jenna.jpg',
  ],
  'frontScreen': _todayScreen,
  'backScreen': _progressScreen,
};

const JsonMap _trust = <String, Object?>{
  'heading': 'Loved by the people who write about apps',
  'press': <Object?>[
    <String, Object?>{
      'name': 'The Daily Ledger',
      'style': 'bold',
      'quote': 'The only habit app we kept past January.',
    },
    <String, Object?>{
      'name': 'Wellspring',
      'style': 'light',
      'quote': 'Calm, clear and quietly addictive.',
    },
    <String, Object?>{
      'name': 'Fieldnote',
      'style': 'italic',
      'quote': 'A masterclass in gentle design.',
    },
    <String, Object?>{
      'name': 'HOMETOWN GAZETTE',
      'style': 'spaced',
      'quote': 'Finally, a streak counter that is kind.',
    },
    <String, Object?>{
      'name': 'Pocket Review',
      'style': 'bold',
      'quote': 'Small app, big difference.',
    },
  ],
  'awards': <Object?>[
    <String, Object?>{
      'title': 'App of the Day',
      'issuer': 'Pocket Review, 2026',
      'icon': 'award',
    },
    <String, Object?>{
      'title': "Editors' Choice",
      'issuer': 'Fieldnote, 2026',
      'icon': 'star',
    },
    <String, Object?>{
      'title': 'Best Wellbeing App',
      'issuer': 'Wellspring Awards, 2025',
      'icon': 'heart',
    },
  ],
};

const JsonMap _features = <String, Object?>{
  'eyebrow': 'Features',
  'title': 'Everything you need, nothing you do not',
  'subtitle':
      'Four calm screens cover the whole habit loop: check in, see your '
      'progress, look back and stay on track.',
  'items': <Object?>[
    <String, Object?>{
      'id': 'check-in',
      'tabLabel': 'Check-in',
      'icon': 'task',
      'title': 'One tap a day is all it takes',
      'body':
          'Your habits live on a single calm screen. Tick them off as you go, '
          'see how the day is shaping up and let the ring close itself.',
      'bullets': <Object?>[
        'Habits ordered by the time of day you do them',
        'Partial credit for goals like steps and water',
        'Works offline and syncs when you are back',
      ],
      'screen': _todayScreen,
    },
    <String, Object?>{
      'id': 'insights',
      'tabLabel': 'Insights',
      'icon': 'insights',
      'title': 'See your momentum, not just your misses',
      'body':
          'Weekly charts and per-habit progress show what is working. '
          'Streak Freeze keeps one slip from erasing a month of effort.',
      'bullets': <Object?>[
        'A weekly chart that rewards consistency',
        'Streak Freeze for the days life gets in the way',
        'A Sunday summary you will actually read',
      ],
      'screen': _progressScreen,
    },
    <String, Object?>{
      'id': 'calendar',
      'tabLabel': 'Calendar',
      'icon': 'calendar',
      'title': 'Every perfect day, at a glance',
      'body':
          'Look back over the month and see the days you showed up. '
          'Tap any day to add a note about what helped.',
      'bullets': <Object?>[
        'A month view with your perfect days marked',
        'Notes on any day, searchable later',
        'Export your history whenever you like',
      ],
      'screen': _calendarScreen,
    },
    <String, Object?>{
      'id': 'reminders',
      'tabLabel': 'Reminders',
      'icon': 'bell',
      'title': 'Reminders that know when to stay quiet',
      'body':
          'Choose when Ember nudges you and when it stays out of the way. '
          'Streak alerts only fire when your streak is actually at risk.',
      'bullets': <Object?>[
        'One daily reminder, at the time you pick',
        'Streak alerts only when you need them',
        'Dark mode, haptics and sounds, your way',
      ],
      'screen': _settingsScreen,
    },
  ],
};

const JsonMap _howItWorks = <String, Object?>{
  'eyebrow': 'How it works',
  'title': 'From download to daily routine in three steps',
  'subtitle': 'No sign-up wall, no setup marathon. Start in under a minute.',
  'steps': <Object?>[
    <String, Object?>{
      'icon': 'flag',
      'title': 'Pick your goals',
      'description':
          'Choose up to three things you want to build. Ember suggests small, '
          'realistic habits for each one.',
    },
    <String, Object?>{
      'icon': 'task',
      'title': 'Check in daily',
      'description':
          'Open Ember, tick off what you did and close it again. Most people '
          'finish in under ten seconds.',
    },
    <String, Object?>{
      'icon': 'insights',
      'title': 'Watch it compound',
      'description':
          'Streaks, charts and your calendar turn small wins into proof you '
          'can see, and a reason to keep going.',
    },
  ],
};

const JsonMap _gallery = <String, Object?>{
  'eyebrow': 'Screens',
  'title': 'A closer look inside Ember',
  'subtitle': 'Swipe through the app, or use the arrow buttons.',
  'slides': <Object?>[
    <String, Object?>{
      'title': 'Choose your goals',
      'caption': 'Start with what matters to you.',
      'screen': _goalsScreen,
    },
    <String, Object?>{
      'title': 'Check in',
      'caption': 'Your whole day on one screen.',
      'screen': _todayScreen,
    },
    <String, Object?>{
      'title': 'Track progress',
      'caption': 'Weekly charts that reward consistency.',
      'screen': _progressScreen,
    },
    <String, Object?>{
      'title': 'Look back',
      'caption': 'Every perfect day, marked.',
      'screen': _calendarScreen,
    },
    <String, Object?>{
      'title': 'Make it yours',
      'caption': 'Reminders on your terms.',
      'screen': _settingsScreen,
    },
  ],
};

const JsonMap _stats = <String, Object?>{
  'title': 'Ember by the numbers',
  'caption': 'Two million people check in every single day.',
  'photo': 'assets/images/lifestyle-street.jpg',
  'photoLabel': 'A man checking his phone on a sunny city street',
  'stats': <Object?>[
    <String, Object?>{
      'label': 'Downloads',
      'value': '2.4M+',
      'description': 'Installs on iOS and Android',
    },
    <String, Object?>{
      'label': 'App rating',
      'value': '4.8',
      'description': 'Average from 120K ratings',
    },
    <String, Object?>{
      'label': 'Countries',
      'value': '92',
      'description': 'Countries and regions',
    },
    <String, Object?>{
      'label': 'Uptime',
      'value': '99.98%',
      'description': 'Sync availability, last 12 months',
    },
  ],
};

const JsonMap _reviews = <String, Object?>{
  'eyebrow': 'Reviews',
  'title': 'Rated 4.8 by people who stuck with it',
  'subtitle': 'Real words from the App Store and Google Play.',
  // Counts per star. The total, the average and the bars are derived.
  'distribution': <String, Object?>{
    '5': 103200,
    '4': 10800,
    '3': 3000,
    '2': 1200,
    '1': 1800,
  },
  'reviews': <Object?>[
    <String, Object?>{
      'id': 'r1',
      'title': 'My 200 day streak says it all',
      'body':
          'I have tried every habit app. Ember is the first one that does not '
          'make me feel guilty when I miss a day. Streak Freeze is genius.',
      'author': 'Priya S.',
      'date': '2026-09-28',
      'rating': 5,
      'avatar': 'assets/images/avatar-priya.jpg',
    },
    <String, Object?>{
      'id': 'r2',
      'title': 'Beautiful and calm',
      'body':
          'The check-in screen is perfect. It takes ten seconds and I never '
          'dread opening it. The weekly summary is a lovely touch.',
      'author': 'Mei L.',
      'date': '2026-09-14',
      'rating': 5,
      'avatar': 'assets/images/avatar-mei.jpg',
    },
    <String, Object?>{
      'id': 'r3',
      'title': 'Finally, reminders that are not annoying',
      'body':
          'It only nudges me when my streak is at risk. I turned off every '
          'other habit app notification after a week.',
      'author': 'Adaeze O.',
      'date': '2026-08-30',
      'rating': 5,
      'avatar': 'assets/images/avatar-adaeze.jpg',
    },
    <String, Object?>{
      'id': 'r4',
      'title': 'Great, wish it had widgets',
      'body':
          'Everything I need is here and it is fast. A home screen widget '
          'would make it a five. Support replied within a day.',
      'author': 'Jenna R.',
      'date': '2026-08-12',
      'rating': 4,
      'avatar': 'assets/images/avatar-jenna.jpg',
    },
    <String, Object?>{
      'id': 'r5',
      'title': 'Helped me sleep better',
      'body':
          'I started with one habit, lights out by 11. Three months later I '
          'have five habits and I have never slept better.',
      'author': 'Tunde A.',
      'date': '2026-07-22',
      'rating': 5,
      'avatar': 'assets/images/avatar-tunde.jpg',
    },
    <String, Object?>{
      'id': 'r6',
      'title': 'Simple and honest pricing',
      'body':
          'The free version is genuinely useful. I upgraded for the insights '
          'and have not regretted it. No dark patterns.',
      'author': 'Lucia M.',
      'date': '2026-06-09',
      'rating': 4,
      'avatar': 'assets/images/avatar-lucia.jpg',
    },
  ],
  'writeReview': <String, Object?>{
    'label': 'Write a review',
    'toastTitle': 'Thanks for sharing',
    'toastMessage':
        'Reviews are written in the app, so we know you really use Ember. '
        'Open Ember and tap Settings, then Rate Ember.',
  },
};

const JsonMap _pricing = <String, Object?>{
  'eyebrow': 'Pricing',
  'title': 'Free to start. Premium when you are ready.',
  'subtitle':
      'The free plan is genuinely useful. Premium adds the full picture and '
      'pays for the people who build Ember.',
  'currency': r'$',
  'yearlyDiscountPercent': 40,
  'monthlyLabel': 'Monthly',
  'yearlyLabel': 'Yearly',
  'plans': <Object?>[
    <String, Object?>{
      'id': 'free',
      'name': 'Free',
      'description': 'Everything you need to build your first habits.',
      'monthlyPrice': 0,
      'unit': 'forever',
      'highlighted': false,
      'cta': <String, Object?>{'label': 'Download free', 'href': '#download'},
      'featuresHeading': 'Includes',
      'features': <Object?>[
        'Up to 5 habits',
        'Daily check-in and streaks',
        'Calendar view',
        'One daily reminder',
      ],
    },
    <String, Object?>{
      'id': 'premium',
      'name': 'Premium',
      'description': 'For people who want the full picture.',
      'monthlyPrice': 6.99,
      'unit': 'per month',
      'highlighted': true,
      'badge': '7-day free trial',
      'cta': <String, Object?>{
        'label': 'Start free trial',
        'href': 'https://ember.example/trial?plan=premium&period={period}',
      },
      'featuresHeading': 'Everything in Free, plus',
      'features': <Object?>[
        'Unlimited habits',
        'Insights, charts and weekly summary',
        'Streak Freeze, 2 per month',
        'Home screen widgets and dark icon',
        'Export your data any time',
      ],
    },
  ],
  'compareNote':
      'Prices in US dollars. Cancel any time in your store settings.',
  'compare': <String, Object?>{'label': 'Read the FAQ', 'href': '#faq'},
};

const JsonMap _faq = <String, Object?>{
  'eyebrow': 'FAQ',
  'title': 'Questions, answered',
  'subtitle': 'Cannot find what you are looking for? We are happy to help.',
  'items': <Object?>[
    <String, Object?>{
      'id': 'free',
      'question': 'Is Ember really free?',
      'answer':
          'Yes. The free plan includes up to five habits, streaks, the '
          'calendar and a daily reminder, with no ads and no time limit. '
          'Premium adds insights and unlimited habits.',
    },
    <String, Object?>{
      'id': 'devices',
      'question': 'Which phones does Ember run on?',
      'answer':
          'iPhone with iOS 15 or later, and Android phones with Android 9 '
          'or later. Your habits sync between devices signed in to the same '
          'account.',
    },
    <String, Object?>{
      'id': 'offline',
      'question': 'Does it work offline?',
      'answer':
          'Everything works without a connection. Ember saves your check-ins '
          'on your phone and syncs them the next time you are online.',
    },
    <String, Object?>{
      'id': 'trial',
      'question': 'How does the free trial work?',
      'answer':
          'Premium starts with a 7-day trial. You will not be charged until '
          'the trial ends, and you can cancel any time in your store '
          'settings before then.',
    },
    <String, Object?>{
      'id': 'privacy',
      'question': 'Is my data private?',
      'answer':
          'Your habits are yours. They are encrypted in transit and at rest, '
          'we never sell data, and you can export or delete everything from '
          'Settings.',
    },
    <String, Object?>{
      'id': 'streak',
      'question': 'What happens if I miss a day?',
      'answer':
          'Your streak pauses rather than breaks if you have a Streak Freeze '
          'available. Premium members get two each month, and everyone gets '
          'one when they join.',
    },
  ],
  'contactText': 'Still curious?',
  'contact': <String, Object?>{
    'label': 'Talk to support',
    'href': 'mailto:hello@ember.example',
  },
};

const JsonMap _download = <String, Object?>{
  'eyebrow': 'Get the app',
  'title': 'Take Ember with you',
  'subtitle':
      'Scan the code with your camera, text yourself a link, or go straight '
      'to your store. It takes less than a minute.',
  'formTitle': 'Send me the link',
  'placeholder': 'Email or phone',
  'buttonLabel': 'Send link',
  'privacyNote':
      'We use your details once to send the link, then delete them. Message '
      'and data rates may apply.',
  'successTitle': 'Link on its way',
  'successMessage':
      'Check your messages. The download link should arrive in a minute.',
  'storesHeading': 'Or download directly',
  'qr': <String, Object?>{
    'title': 'Scan to download',
    'caption': 'Point your phone camera at the code.',
    'badge': 'Demo',
    'demoNote': 'Demo pattern: this is not a scannable code.',
    'payload': 'https://ember.example/get',
  },
};

const JsonMap _footer = <String, Object?>{
  'description':
      'Ember is the friendly habit coach that helps you build routines that '
      'last, one small win at a time.',
  'columns': <Object?>[
    <String, Object?>{
      'title': 'Product',
      'links': <Object?>[
        <String, Object?>{'label': 'Features', 'href': '#features'},
        <String, Object?>{'label': 'Pricing', 'href': '#pricing'},
        <String, Object?>{'label': 'Reviews', 'href': '#reviews'},
        <String, Object?>{'label': 'Download', 'href': '#download'},
      ],
    },
    <String, Object?>{
      'title': 'Company',
      'links': <Object?>[
        <String, Object?>{'label': 'About', 'href': '/about'},
        <String, Object?>{'label': 'Careers', 'href': '/careers'},
        <String, Object?>{'label': 'Press kit', 'href': '/press'},
        <String, Object?>{
          'label': 'Contact',
          'href': 'mailto:hello@ember.example',
        },
      ],
    },
    <String, Object?>{
      'title': 'Support',
      'links': <Object?>[
        <String, Object?>{'label': 'Help centre', 'href': '/help'},
        <String, Object?>{'label': 'Status', 'href': '/status'},
        <String, Object?>{'label': 'Accessibility', 'href': '/accessibility'},
        <String, Object?>{'label': 'Changelog', 'href': '/changelog'},
      ],
    },
  ],
  'social': <Object?>[
    <String, Object?>{
      'label': 'Ember on the web',
      'icon': 'public',
      'href': 'https://ember.example',
    },
    <String, Object?>{
      'label': 'Ember blog feed',
      'icon': 'rss',
      'href': 'https://ember.example/feed.xml',
    },
    <String, Object?>{
      'label': 'Email Ember',
      'icon': 'mail',
      'href': 'mailto:hello@ember.example',
    },
  ],
  'copyright': '© 2026 Ember Labs. All rights reserved.',
  'legal': <Object?>[
    <String, Object?>{'label': 'Privacy', 'href': '/privacy'},
    <String, Object?>{'label': 'Terms', 'href': '/terms'},
    <String, Object?>{'label': 'Cookies', 'href': '/cookies'},
  ],
};

// ---------------------------------------------------------------------------
// The live phone screens. Each is drawn from Cairn widgets, not an image.
// ---------------------------------------------------------------------------

const JsonMap _todayScreen = <String, Object?>{
  'kind': 'today',
  'title': 'Today',
  'subtitle': 'Friday, 9 October',
  'headline': '3 of 5',
  'caption': 'habits done',
  'tab': 0,
  'description':
      'The Today screen: three of five habits are done, with a progress ring '
      'and a checklist.',
  'items': <Object?>[
    <String, Object?>{
      'label': 'Morning stretch',
      'detail': '7:00 am',
      'icon': 'sun',
      'done': true,
    },
    <String, Object?>{
      'label': 'Meditate 10 min',
      'detail': '8:15 am',
      'icon': 'heart',
      'done': true,
    },
    <String, Object?>{
      'label': 'Walk 8,000 steps',
      'detail': '6,420 steps',
      'icon': 'run',
      'done': true,
    },
    <String, Object?>{
      'label': 'Read 20 pages',
      'detail': '9:30 pm',
      'icon': 'book',
      'done': false,
    },
    <String, Object?>{
      'label': 'Lights out by 11',
      'detail': '10:45 pm',
      'icon': 'sleep',
      'done': false,
    },
  ],
};

const JsonMap _progressScreen = <String, Object?>{
  'kind': 'progress',
  'title': 'Progress',
  'subtitle': 'This week',
  'headline': '12 day streak',
  'caption': 'Your longest yet',
  'tab': 1,
  'description':
      'The Progress screen: a twelve day streak, a bar chart of the week and '
      'completion for each habit.',
  'bars': <Object?>[0.6, 0.8, 1.0, 0.8, 1.0, 0.4, 0.9],
  'barLabels': <Object?>['M', 'T', 'W', 'T', 'F', 'S', 'S'],
  'items': <Object?>[
    <String, Object?>{
      'label': 'Morning stretch',
      'detail': '90%',
      'value': 0.9,
    },
    <String, Object?>{'label': 'Meditate', 'detail': '75%', 'value': 0.75},
    <String, Object?>{
      'label': 'Walk 8,000 steps',
      'detail': '60%',
      'value': 0.6,
    },
    <String, Object?>{'label': 'Read 20 pages', 'detail': '40%', 'value': 0.4},
  ],
};

const JsonMap _calendarScreen = <String, Object?>{
  'kind': 'calendar',
  'title': 'Calendar',
  'subtitle': 'Your perfect days',
  'headline': '7 perfect days',
  'caption': 'so far this month',
  'monthLabel': 'October 2026',
  'daysInMonth': 31,
  'startWeekday': 4,
  'activeDays': <Object?>[1, 2, 3, 5, 6, 7, 8],
  'today': 9,
  'tab': 2,
  'description':
      'The Calendar screen: October 2026 with seven perfect days marked.',
};

const JsonMap _settingsScreen = <String, Object?>{
  'kind': 'settings',
  'title': 'Settings',
  'subtitle': 'Make Ember yours',
  'headline': 'Alex Morgan',
  'caption': '12 day streak',
  'badge': 'Premium',
  'footnote': 'Ember 4.2',
  'tab': 3,
  'description':
      'The Settings screen: switches for the daily reminder, streak alerts, '
      'weekly summary, dark appearance and haptics.',
  'items': <Object?>[
    <String, Object?>{
      'label': 'Daily reminder',
      'detail': 'Every day at 8:00 am',
      'icon': 'bell',
      'on': true,
    },
    <String, Object?>{
      'label': 'Streak alerts',
      'detail': 'Only when at risk',
      'icon': 'fire',
      'on': true,
    },
    <String, Object?>{
      'label': 'Weekly summary',
      'detail': 'Sundays at 6:00 pm',
      'icon': 'mail',
      'on': false,
    },
    <String, Object?>{
      'label': 'Dark appearance',
      'detail': 'Match my phone',
      'icon': 'moon',
      'on': true,
    },
    <String, Object?>{
      'label': 'Haptics',
      'detail': 'A little tap on check-in',
      'icon': 'phone',
      'on': true,
    },
  ],
};

const JsonMap _goalsScreen = <String, Object?>{
  'kind': 'goals',
  'title': 'What do you want to build?',
  'subtitle': 'Pick up to three. You can change them any time.',
  'headline': 'Continue',
  'caption': '3 selected',
  'tab': 0,
  'description':
      'The first screen after install: six goals to choose from, with move '
      'more, sleep better and read daily selected.',
  'items': <Object?>[
    <String, Object?>{'label': 'Move more', 'icon': 'run', 'done': true},
    <String, Object?>{'label': 'Sleep better', 'icon': 'sleep', 'done': true},
    <String, Object?>{'label': 'Read daily', 'icon': 'book', 'done': true},
    <String, Object?>{'label': 'Drink water', 'icon': 'water', 'done': false},
    <String, Object?>{'label': 'Stay calm', 'icon': 'heart', 'done': false},
    <String, Object?>{'label': 'Learn a skill', 'icon': 'edit', 'done': false},
  ],
};
