import React, {useState} from 'react'

export default function App(){
  const [message, setMessage] = useState('')
  const [recipients, setRecipients] = useState('')
  const [result, setResult] = useState(null)

  async function send(e){
    e.preventDefault()
    const body = {
      message,
      recipients: recipients.split(',').map(s => s.trim()).filter(Boolean)
    }
    const res = await fetch('/api/send', {
      method: 'POST',
      headers: {'Content-Type':'application/json'},
      body: JSON.stringify(body)
    })
    const data = await res.json()
    setResult(data)
  }

  return (
    <div style={{maxWidth:800,margin:'2rem auto',fontFamily:'system-ui,Segoe UI'}}>
      <h1>SaveThis — Send Group SMS (Demo)</h1>
      <form onSubmit={send}>
        <div>
          <label>Recipients (comma separated)</label><br/>
          <input value={recipients} onChange={e=>setRecipients(e.target.value)} style={{width:'100%'}} />
        </div>
        <div style={{marginTop:10}}>
          <label>Message</label><br/>
          <textarea value={message} onChange={e=>setMessage(e.target.value)} style={{width:'100%',height:120}} />
        </div>
        <div style={{marginTop:10}}>
          <button type="submit">Send</button>
        </div>
      </form>
      {result && <pre style={{marginTop:20}}>{JSON.stringify(result,null,2)}</pre>}
    </div>
  )
}
