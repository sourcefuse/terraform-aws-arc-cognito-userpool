const express = require("express");
const axios = require("axios");
require("dotenv").config();

const app = express();
const port = 3000;

const {
  COGNITO_DOMAIN,
  CLIENT_ID,
  CLIENT_SECRET,
  REDIRECT_URI,
  REGION
} = process.env;
app.get("/", (req, res) => {
  res.send(`
    <h1>Cognito Test App</h1>
    <p><a href="/login">Login with Cognito</a></p>
  `);
});

// Login route – redirect to Cognito Hosted UI
app.get("/login", (req, res) => {
  const url = `${COGNITO_DOMAIN}/oauth2/authorize?client_id=${CLIENT_ID}&response_type=code&scope=openid+profile+email&redirect_uri=${encodeURIComponent(
    REDIRECT_URI
  )}`;
  res.redirect(url);
});

// Callback route – Cognito redirects back here
app.get("/callback", async (req, res) => {
  const code = req.query.code;
  if (!code) {
    return res.status(400).send("No code received");
  }

  try {
    const tokenUrl = `${COGNITO_DOMAIN}/oauth2/token`;

    const params = new URLSearchParams();
    params.append("grant_type", "authorization_code");
    params.append("client_id", CLIENT_ID);
    params.append("code", code);
    params.append("redirect_uri", REDIRECT_URI);

    const headers = { "Content-Type": "application/x-www-form-urlencoded" };

    if (CLIENT_SECRET) {
      const basicAuth = Buffer.from(`${CLIENT_ID}:${CLIENT_SECRET}`).toString("base64");
      headers["Authorization"] = `Basic ${basicAuth}`;
    }

    const response = await axios.post(tokenUrl, params, { headers });

    res.send(`
      <h1>Login successful!</h1>
      <pre>${JSON.stringify(response.data, null, 2)}</pre>
    `);
  } catch (err) {
    console.error(err.response?.data || err.message);
    res.status(500).send("Error exchanging code for tokens");
  }
});

app.listen(port, () => {
  console.log(`App running on http://localhost:${port}`);
});
