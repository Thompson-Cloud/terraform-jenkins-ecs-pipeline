import React, { useEffect, useState } from 'react'
import './App.css';
import API_URL from './config'

function App() {
  const [successMessage, setSuccessMessage] = useState() 
  const [failureMessage, setFailureMessage] = useState() 

  useEffect(() => {
    const getId = async () => {
      try {
        const resp = await fetch(API_URL)
        setSuccessMessage((await resp.json()).id)
      }
      catch(e) {
        setFailureMessage(e.message)
      }
    }
    getId()
  })

  return (
    <div className="App">
      <h1>TechPathway Challenge-2</h1>
      <h2>Backend Response:</h2>
      <p>{successMessage}</p>
    </div>
  );
}

export default App;
