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
      // Handle email
      if (field.key === 'question_RDZOyJ') {
        formData.email = field.value;
      }
      // Handle first name
      else if (field.key === 'question_9721N5') {
        formData.first_name = field.value;
      }
      // Handle phone
      else if (field.key === 'question_o20JLV') {
        formData.phone = field.value;
      }
      // Handle gender - extract text from options
      else if (field.key === 'question_GRoMAo') {
        if (field.value && field.value.length > 0 && field.options) {
          const selectedOption = field.options.find(opt => opt.id === field.value[0]);
          formData.gender = selectedOption ? selectedOption.text : null;
        }
      }
      // Handle area - extract text from options
      else if (field.key === 'question_O7jRM8') {
        if (field.value && field.value.length > 0 && field.options) {
          const selectedOption = field.options.find(opt => opt.id === field.value[0]);
          formData.area = selectedOption ? selectedOption.text : null;
        }
      }
      // Handle age range - extract text from options
      else if (field.key === 'question_Vz9rOv') {
        if (field.value && field.value.length > 0 && field.options) {
          const selectedOption = field.options.find(opt => opt.id === field.value[0]);
          formData.age_range = selectedOption ? selectedOption.text : null;
        }
      }
      // Handle privacy policy consent
      else if (field.key === 'question_Pz2oJb_a276fce3-5b76-4b23-8ec4-31911ed6aa1a') {
        formData.data_processing_consent = field.value === true;
      }
      // Handle women-only features consent
      else if (field.key === 'question_Pz2oJb_b382c7d6-5638-4a19-bc85-b90ad95c6b26') {
        formData.women_only_features_consent = field.value === true;
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
