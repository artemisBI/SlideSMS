import React, { useState, useEffect } from "react";
import ExcelReader from "./ExcelReader";

const App = () => {
	const [messageBody, setMessageBody] = useState("");
	const [recipients, setRecipients] = useState("");

	const [result, setResult] = useState(null);
	const [sending, setSending] = useState(false);
	const [file, setFile] = useState("");

	const [errorMessage, setErrorMessage] = useState("");

	const send = async (e) => {
		e.preventDefault();

		// Clear previous error message
		setErrorMessage("");

		// Basic validation
		if (!recipients) {
			setErrorMessage("Please provide at least one recipient.");
			return;
		}

		if (!messageBody) {
			setErrorMessage("Message body cannot be empty.");
			return;
		}

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
					`https://api.twilio.com/2010-04-01/Accounts/${
						import.meta.env.VITE_TWILIO_ACCOUNT_SID
					}/Messages.json`,
					{
						method: "POST",
						headers: {
							Authorization:
								"Basic " +
								btoa(
									`${import.meta.env.VITE_TWILIO_ACCOUNT_SID}:${
										import.meta.env.VITE_TWILIO_AUTH_TOKEN
									}`
								),
						},
						body: new URLSearchParams({
							From: import.meta.env.VITE_TWILIO_FROM_NUMBER,
							To: `+1${recipient}`,
							Body: `${message.body}\n\n - SaveThis — Send Group SMS (Demo)`,
						}),
					}
				)
			)
		);

		const data = await Promise.all(resList.map((res) => res.json()));
		setResult(data);
		setSending(false);
	};

	useEffect(() => {
		if (!sending) {
			// clean up the form after sending
			setMessageBody("");
			setRecipients("");
			setFile("");
		}
	}, [sending]);

	return (
		<div style={{ maxWidth: 800, margin: "2rem auto", fontFamily: "system-ui,Segoe UI" }}>
			<h1>SaveThis — Send Group SMS (Demo)</h1>
			<form onSubmit={send}>
				<ExcelReader
					recipients={recipients}
					setRecipients={setRecipients}
					setSending={setSending}
					file={file}
				/>
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
			{errorMessage && <p style={{ color: "red", marginTop: "10px" }}>{errorMessage}</p>}
			{result && <pre style={{ marginTop: 20 }}>{JSON.stringify(result, null, 2)}</pre>}
		</div>
	);
};

export default App;
