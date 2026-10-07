import { Routes, Route } from 'react-router-dom'
import HomePage from './pages/HomePage'
import LearnPage from './pages/LearnPage'
import ProfilePage from './pages/ProfilePage'
import InteractionTestPage from './pages/InteractionTestPage'

function App() {
  return (
    <div className="app">
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/learn/:kpId" element={<LearnPage />} />
        <Route path="/profile" element={<ProfilePage />} />
        <Route path="/test/interaction" element={<InteractionTestPage />} />
      </Routes>
    </div>
  )
}

export default App
