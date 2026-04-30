import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import useAuthStore from '../store/useAuthStore';

export default function RegisterPage() {
  const [form, setForm] = useState({
    username: '', email: '', password: '', fullName: '', phoneNumber: ''
  });
  const [loading, setLoading] = useState(false);
  const { register, error, clearError } = useAuthStore();
  const navigate = useNavigate();

  const handleChange = (e) => {
    clearError();
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      await register(form);
      navigate('/');
    } catch { /* error set in store */ } finally {
      setLoading(false);
    }
  };

  return (
    <div className="gradient-bg min-h-screen flex items-center justify-center p-4">
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-1/3 right-1/3 w-96 h-96 bg-purple-500/10 rounded-full blur-3xl animate-float" />
      </div>

      <motion.div
        initial={{ opacity: 0, y: 30 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
        className="w-full max-w-md"
      >
        <div className="glass-card-dark p-8">
          <div className="text-center mb-8">
            <h1 className="text-3xl font-bold text-gradient mb-2">🚗 DriveON</h1>
            <p className="text-gray-400">Ro'yxatdan o'tish</p>
          </div>

          {error && (
            <div className="mb-6 p-3 bg-red-500/10 border border-red-500/30 rounded-xl text-red-400 text-sm text-center">
              {error}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-gray-300 text-sm font-medium mb-1.5">To'liq ism</label>
              <input type="text" name="fullName" value={form.fullName} onChange={handleChange} className="input-field" placeholder="Jasurbek Toshmatov" required />
            </div>
            <div>
              <label className="block text-gray-300 text-sm font-medium mb-1.5">Username</label>
              <input type="text" name="username" value={form.username} onChange={handleChange} className="input-field" placeholder="jasurbek" required />
            </div>
            <div>
              <label className="block text-gray-300 text-sm font-medium mb-1.5">Email</label>
              <input type="email" name="email" value={form.email} onChange={handleChange} className="input-field" placeholder="jasurbek@mail.uz" required />
            </div>
            <div>
              <label className="block text-gray-300 text-sm font-medium mb-1.5">Telefon</label>
              <input type="tel" name="phoneNumber" value={form.phoneNumber} onChange={handleChange} className="input-field" placeholder="+998901234567" />
            </div>
            <div>
              <label className="block text-gray-300 text-sm font-medium mb-1.5">Parol</label>
              <input type="password" name="password" value={form.password} onChange={handleChange} className="input-field" placeholder="Kamida 6 belgi" required />
            </div>

            <button type="submit" disabled={loading} className="btn-primary w-full flex items-center justify-center gap-2 disabled:opacity-50 mt-2">
              {loading ? <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" /> : "Ro'yxatdan o'tish"}
            </button>
          </form>

          <div className="mt-6 text-center">
            <p className="text-gray-500 text-sm">
              Akkauntingiz bormi?{' '}
              <Link to="/login" className="text-indigo-400 hover:text-indigo-300 font-medium transition-colors">Kirish</Link>
            </p>
          </div>
        </div>
      </motion.div>
    </div>
  );
}
