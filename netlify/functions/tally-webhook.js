// Netlify Function to handle Tally webhook and insert into Supabase
// This function receives Tally form submissions and stores them in your waitlist_users table

const { createClient } = require('@supabase/supabase-js');

exports.handler = async (event, context) => {
  // Only allow POST requests
  if (event.httpMethod !== 'POST') {
    return {
      statusCode: 405,
      body: JSON.stringify({ error: 'Method Not Allowed' })
    };
  }

  try {
    // Initialize Supabase client
    const supabaseUrl = process.env.SUPABASE_URL;
    const supabaseKey = process.env.SUPABASE_ANON_KEY;
    
    if (!supabaseUrl || !supabaseKey) {
      console.error('Missing Supabase credentials');
      return {
        statusCode: 500,
        body: JSON.stringify({ error: 'Server configuration error' })
      };
    }

    const supabase = createClient(supabaseUrl, supabaseKey);

    // Parse the incoming webhook data from Tally
    const data = JSON.parse(event.body);
    
    // Log the incoming data for debugging
    console.log('Received webhook data:', JSON.stringify(data, null, 2));

    // Extract form fields from Tally webhook
    // Tally sends data in format: { eventId, eventType, createdAt, data: { fields: [...] } }
    const fields = data.data?.fields || [];
    
    // Map Tally fields to our database structure
    const formData = {};
    
    fields.forEach(field => {
      switch(field.key) {
        case 'email':
          formData.email = field.value;
          break;
        case 'phone':
        case 'phone_number':
          formData.phone = field.value;
          break;
        case 'first_name':
        case 'name':
          formData.first_name = field.value;
          break;
        case 'gender':
          formData.gender = field.value;
          break;
        case 'area':
        case 'location':
        case 'city':
          formData.area = field.value;
          break;
        case 'age_range':
        case 'age':
          formData.age_range = field.value;
          break;
        case 'data_processing_consent':
        case 'privacy_consent':
          formData.data_processing_consent = field.value === 'Yes' || field.value === true;
          break;
        case 'marketing_consent':
          formData.marketing_consent = field.value === 'Yes' || field.value === true;
          break;
        case 'women_only_features_consent':
          formData.women_only_features_consent = field.value === 'Yes' || field.value === true;
          break;
      }
    });

    // Validate required fields
    if (!formData.email) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: 'Email is required' })
      };
    }

    // Add metadata
    formData.referral_source = 'tally_form';
    formData.ip_address = event.headers['x-forwarded-for'] || event.headers['x-real-ip'];
    formData.user_agent = event.headers['user-agent'];

    // Insert into Supabase
    const { data: insertedData, error } = await supabase
      .from('waitlist_users')
      .insert([formData])
      .select();

    if (error) {
      console.error('Supabase insertion error:', error);
      
      // Handle duplicate email error gracefully
      if (error.code === '23505' && error.message.includes('email')) {
        return {
          statusCode: 200,
          body: JSON.stringify({ 
            message: 'Email already registered',
            status: 'duplicate'
          })
        };
      }
      
      return {
        statusCode: 500,
        body: JSON.stringify({ error: 'Database insertion failed', details: error.message })
      };
    }

    console.log('Successfully inserted user:', insertedData[0]?.id);

    // Optional: Send welcome email here
    // await sendWelcomeEmail(formData.email, formData.first_name);

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: 'Waitlist signup successful!',
        userId: insertedData[0]?.id,
        status: 'success'
      })
    };

  } catch (error) {
    console.error('Webhook processing error:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ 
        error: 'Internal server error',
        message: error.message 
      })
    };
  }
};
