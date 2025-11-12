import React, { useState } from "react";

export default function App() {
  const [messageBody, setMessageBody] = useState("");
  const [recipients, setRecipients] = useState("");
  const [result, setResult] = useState(null);

  async function send(e) {
    e.preventDefault();

    const message = {
      body: messageBody,
      to: recipients
        .split(",")
        .map((s) => s.trim())
        .filter(Boolean),
    };

    const resList = await Promise.all(
      message.to.map((recipient) =>
        fetch(
          `https://api.twilio.com/2010-04-01/Accounts/${process.env.TWILIO_ACCOUNT_SID}/Messages.json`,
          {
            method: "POST",
            headers: {
              Authorization:
                "Basic " +
                btoa(
                  `${process.env.TWILIO_ACCOUNT_SID}:${process.env.TWILIO_AUTH_TOKEN}`
                ),
            },
            body: new URLSearchParams({
              From: process.env.TWILIO_FROM_NUMBER,
              To: `+1${recipient}`,
              Body: `${message.body}\n\n - SaveThis — Send Group SMS (Demo)`,
            }),
          }
        )
      )
    );

    const data = await Promise.all(resList.map((res) => res.json()));
    setResult(data);
  }

  return (
    <div style={{ maxWidth: 800, margin: "2rem auto", fontFamily: "system-ui,Segoe UI" }}>
      <h1>SaveThis — Send Group SMS (Demo)</h1>
      <form onSubmit={send}>
        <div>
          <label>Recipients (comma separated)</label>
          <br />
          <input
            value={recipients}
            onChange={(e) => setRecipients(e.target.value)}
            style={{ width: "100%" }}
          />
        </div>
        <div style={{ marginTop: 10 }}>
          <label>Message</label>
          <br />
          <textarea
            value={messageBody}
            onChange={(e) => setMessageBody(e.target.value)}
            style={{ width: "100%", height: 120 }}
          />
        </div>
        <div style={{ marginTop: 10 }}>
          <button type="submit">Send</button>
        </div>
      </form>
      {result && <pre style={{ marginTop: 20 }}>{JSON.stringify(result, null, 2)}</pre>}
    </div>
  );
}
