import { createBrowserRouter, Navigate } from 'react-router-dom';
import { HomePage, LearnPage, ProfilePage } from '../pages';

/**
 * 应用路由配置
 */
export const router = createBrowserRouter([
  {
    path: '/',
    element: <HomePage />,
  },
  {
    path: '/learn/:knowledgePointId',
    element: <LearnPage />,
  },
  {
    path: '/profile',
    element: <ProfilePage />,
  },
  {
    path: '*',
    element: <Navigate to="/" replace />,
  },
]);

export default router;
