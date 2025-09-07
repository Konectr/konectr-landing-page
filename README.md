# Konectr MVP - Monorepo

🌟 **Real Adventures with Real People, Right Now**

Monorepo for Konectr - the social networking platform that connects people for genuine real-world experiences. This repository contains both the web landing page and mobile application.

## 🚀 Live Site

- **Production**: [konectrapp.com](https://konectrapp.com)
- **Staging**: [Netlify auto-generated URL]

## 🛠️ Tech Stack

### Web Landing Page
- **Frontend**: HTML5, CSS3, JavaScript
- **Animations**: GSAP with ScrollTrigger
- **Form**: Tally.so integration
- **Deployment**: Netlify
- **Domain**: konectrapp.com

### Mobile App
- **Framework**: Flutter (via FlutterFlow)
- **State Management**: Provider/Riverpod
- **Backend**: Supabase
- **Platforms**: iOS & Android
- **Design System**: Konectr brand guidelines

## 🔐 Security Features

- PDPA Malaysia compliant
- Supabase Row Level Security
- Encrypted data storage
- Rate limiting and spam protection
- Secure form handling

## 📱 Features

- ✅ Mobile responsive design
- ✅ Professional animations
- ✅ Secure waitlist collection
- ✅ Social media integration
- ✅ SEO optimized
- ✅ Fast loading performance

## 🏗️ Project Structure

```
├── apps/
│   ├── web/                    # Web landing page
│   │   ├── index.html          # Main landing page
│   │   ├── netlify.toml        # Netlify configuration
│   │   ├── netlify/functions/  # Serverless functions
│   │   └── package.json        # Web dependencies
│   │
│   └── mobile/                 # Mobile application
│       └── konectr/           # Flutter project
│           ├── android/       # Android specific
│           ├── ios/          # iOS specific
│           ├── lib/          # Flutter code
│           │   └── src/      # Konectr domain structure
│           │       ├── app/
│           │       ├── features/
│           │       ├── entities/
│           │       └── shared/
│           └── pubspec.yaml  # Flutter dependencies
│
├── docs/                      # Shared documentation
│   ├── security-*.md         # Security implementation guides
│   ├── mvp-architecture.md   # Technical architecture
│   └── *.sql                # Database setup scripts
│
├── ops/                      # Operations & deployment
│   └── policies/            # Database policies
│
├── KONECTR_MOBILE_RULES.md  # Engineering doctrine
└── README.md                # This file
```

## 🚀 Deployment

This repository auto-deploys to Netlify:

1. **Push to main branch** → Automatic deployment
2. **Preview branches** → Branch-specific preview URLs
3. **Custom domain** → konectrapp.com with SSL

## 🔧 Local Development

### Web Landing Page
```bash
# Navigate to web directory
cd apps/web

# Install dependencies
npm install

# Open index.html in browser
open index.html
```

### Mobile App
```bash
# Navigate to mobile directory
cd apps/mobile/konectr

# Get Flutter dependencies
flutter pub get

# Run on iOS simulator
flutter run -d ios

# Run on Android emulator
flutter run -d android
```

## 📊 Performance

- **Loading Time**: < 3 seconds
- **Mobile Score**: 95+
- **SEO Score**: 100
- **Accessibility**: WCAG AA compliant

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Contact

- **Email**: hello@konectr.app
- **Website**: [konectrapp.com](https://konectrapp.com)
- **Social**: [@konectrapp](https://instagram.com/konectrapp)

## 📄 License

© 2025 Konectr. All rights reserved.

---

**Built with ❤️ for real connections**
