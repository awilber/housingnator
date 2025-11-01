import React from 'react'
import './App.css'

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <h1>HousingNator</h1>
        <p>Find your perfect rental - traditional and non-traditional options</p>
        <div className="features">
          <div className="feature">
            <h3>🏠 Traditional Rentals</h3>
            <p>Apartments, houses, condos through standard channels</p>
          </div>
          <div className="feature">
            <h3>🌟 Non-Traditional Options</h3>
            <p>Co-living, short-term, rent-to-own, cooperatives</p>
          </div>
          <div className="feature">
            <h3>🔍 Advanced Search</h3>
            <p>Filter by location, price, amenities, and rental type</p>
          </div>
        </div>
      </header>
    </div>
  )
}

export default App