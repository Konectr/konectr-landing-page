// Test script to verify webhook function is working
// Run this with: node test-webhook.js

const fetch = require('node-fetch'); // You may need to install: npm install node-fetch

// Test data that mimics what Tally sends
const testPayload = {
  eventId: "test-12345",
  eventType: "FORM_RESPONSE",
  createdAt: "2025-09-01T10:30:00Z",
  data: {
    responseId: "test-response-123",
    submissionId: "test-submission-456",
    respondentId: "test-respondent-789",
    formId: "mY1xRq",
    formName: "Konectr Waitlist Verified Profiles Only ✅",
    createdAt: "2025-09-01T10:30:00Z",
    fields: [
      {
        key: "email",
        label: "Email",
        type: "INPUT_EMAIL",
        value: "test.user@example.com"
      },
      {
        key: "first_name",
        label: "First Name", 
        type: "INPUT_TEXT",
        value: "Test User"
      },
      {
        key: "gender",
        label: "Gender",
        type: "MULTIPLE_CHOICE",
        value: "Female"
      },
      {
        key: "area",
        label: "Area in KL",
        type: "DROPDOWN",
        value: "Bangsar"
      },
      {
        key: "age_range",
        label: "Age Range",
        type: "MULTIPLE_CHOICE", 
        value: "26-35"
      },
      {
        key: "data_processing_consent",
        label: "I agree to Konectr's Privacy Policy",
        type: "CHECKBOX",
        value: "Yes"
      },
      {
        key: "marketing_consent",
        label: "I want updates about women-only features",
        type: "CHECKBOX",
        value: "Yes"
      }
    ]
  }
};

async function testWebhook() {
  const webhookUrl = 'https://konectrapp.com/.netlify/functions/tally-webhook';
  
  console.log('🧪 Testing webhook function...');
  console.log('📍 URL:', webhookUrl);
  
  try {
    const response = await fetch(webhookUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'Konectr-Test-Client/1.0'
      },
      body: JSON.stringify(testPayload)
    });

    const responseText = await response.text();
    
    console.log('\n📊 Response Status:', response.status);
    console.log('📋 Response Headers:', Object.fromEntries(response.headers));
    console.log('📄 Response Body:', responseText);

    if (response.ok) {
      console.log('\n✅ SUCCESS: Webhook function is working!');
      console.log('🎯 Next: Check your Supabase database for the new entry');
    } else {
      console.log('\n❌ ERROR: Webhook function failed');
      console.log('🔍 Check your Netlify function logs for details');
    }

  } catch (error) {
    console.error('\n💥 NETWORK ERROR:', error.message);
    console.log('🔍 Possible issues:');
    console.log('   - Netlify site not deployed');
    console.log('   - Function not found');
    console.log('   - Network connectivity issue');
  }
}

testWebhook();
