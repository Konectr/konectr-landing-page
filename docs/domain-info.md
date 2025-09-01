# Konectr Domain Information

## Domain Details
- **Domain**: konectrapp.com
- **Registrar**: Namecheap
- **Status**: Already purchased and available
- **Owner**: Konectr CEO

## DNS Configuration for Netlify
When ready to connect to Netlify:

### Netlify DNS Settings
1. In Netlify: Site Settings → Domain Management
2. Add custom domain: konectrapp.com
3. Add www subdomain: www.konectrapp.com

### Namecheap DNS Records to Add
```
Type: A Record
Host: @
Value: 75.2.60.5

Type: CNAME
Host: www
Value: konectrapp.netlify.app
```

## SSL Certificate
- Netlify will automatically provide FREE SSL certificate
- Site will be accessible via https://konectrapp.com

## Email Setup (Future)
Potential email addresses:
- hello@konectrapp.com (general inquiries)
- privacy@konectrapp.com (PDPA/privacy requests)
- safety@konectrapp.com (safety reports)
- support@konectrapp.com (user support)

## Subdomains (Future Planning)
- app.konectrapp.com (mobile app web version)
- admin.konectrapp.com (admin dashboard)
- api.konectrapp.com (API endpoint)
- crowns.konectrapp.com (venue partner platform)
