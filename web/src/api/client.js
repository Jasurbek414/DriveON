const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080';

class ApiClient {
  constructor() {
    this.baseUrl = API_BASE_URL;
  }

  getToken() {
    return localStorage.getItem('accessToken');
  }

  async request(endpoint, options = {}) {
    const token = this.getToken();
    const headers = {
      'Content-Type': 'application/json',
      ...options.headers,
    };

    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    const response = await fetch(`${this.baseUrl}${endpoint}`, {
      ...options,
      headers,
    });

    if (response.status === 401) {
      localStorage.removeItem('accessToken');
      localStorage.removeItem('refreshToken');
      window.location.href = '/login';
      throw new Error('Unauthorized');
    }

    if (!response.ok) {
      const error = await response.json().catch(() => ({ message: 'Xatolik yuz berdi' }));
      throw new Error(error.message || `HTTP ${response.status}`);
    }

    return response.json();
  }

  get(endpoint) {
    return this.request(endpoint, { method: 'GET' });
  }

  post(endpoint, data) {
    return this.request(endpoint, {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  put(endpoint, data) {
    return this.request(endpoint, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  }

  patch(endpoint, data) {
    return this.request(endpoint, {
      method: 'PATCH',
      body: data ? JSON.stringify(data) : undefined,
    });
  }

  delete(endpoint) {
    return this.request(endpoint, { method: 'DELETE' });
  }

  // Auth
  login(credentials) { return this.post('/api/auth/login', credentials); }
  register(data) { return this.post('/api/auth/register', data); }

  // Users
  getMe() { return this.get('/api/users/me'); }
  getUsers() { return this.get('/api/users'); }
  getDrivers() { return this.get('/api/users/drivers'); }

  // Orders
  getOrders(page = 0, size = 20) { return this.get(`/api/orders?page=${page}&size=${size}`); }
  getOrder(id) { return this.get(`/api/orders/${id}`); }
  createOrder(data) { return this.post('/api/orders', data); }
  assignDriver(orderId, driverId) { return this.patch(`/api/orders/${orderId}/assign/${driverId}`); }
  updateOrderStatus(orderId, status) { return this.patch(`/api/orders/${orderId}/status/${status}`); }
  getDashboardStats() { return this.get('/api/orders/dashboard/stats'); }
}

export const api = new ApiClient();
export default api;
