
const token = 'AAGKNgAA7GbN_3Q3gxavQquQ0NpCLU7Q9aJpGv9nsDLO5w';
const url = 'https://gatewayapi.telegram.org/sendVerificationMessage';
const body = {
    phone_number: '+998901234567',
    code: '1234',
    code_length: 4,
    ttl: 60
};

console.log('Testing Telegram Gateway API...');
fetch(url, {
    method: 'POST',
    headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
    },
    body: JSON.stringify(body)
})
.then(res => res.json().then(data => {
    console.log('HTTP Status:', res.status);
    console.log('Response Body:', JSON.stringify(data, null, 2));
}))
.catch(err => {
    console.error('Fetch Error:', err);
});
