import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import api from '../api/client';

export default function DashboardPage() {
  const [stats, setStats] = useState(null);
  const [recentOrders, setRecentOrders] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => { loadData(); }, []);

  const loadData = async () => {
    try {
      const [s, o] = await Promise.all([api.getDashboardStats(), api.getOrders(0, 5)]);
      setStats(s);
      setRecentOrders(o.content || []);
    } catch (err) { console.error(err); } finally { setLoading(false); }
  };

  const cards = [
    { key: 'totalOrders', label: 'Jami', icon: '📦', color: 'from-blue-500 to-cyan-500' },
    { key: 'pendingOrders', label: 'Kutilmoqda', icon: '⏳', color: 'from-yellow-500 to-orange-500' },
    { key: 'activeOrders', label: 'Faol', icon: '🚚', color: 'from-emerald-500 to-green-500' },
    { key: 'deliveredOrders', label: 'Yetkazilgan', icon: '✅', color: 'from-indigo-500 to-purple-500' },
    { key: 'cancelledOrders', label: 'Bekor', icon: '❌', color: 'from-red-500 to-pink-500' },
    { key: 'totalUsers', label: 'Foydalanuvchilar', icon: '👥', color: 'from-violet-500 to-fuchsia-500' },
  ];

  const badge = (s) => {
    const m = { PENDING:'badge-pending', DELIVERED:'badge-delivered', CANCELLED:'badge-cancelled' };
    return m[s] || 'badge-active';
  };

  if (loading) return <div className="flex items-center justify-center h-64"><div className="w-10 h-10 border-4 border-indigo-500 border-t-transparent rounded-full animate-spin" /></div>;

  return (
    <div className="space-y-8">
      <div><h1 className="text-2xl font-bold text-white mb-1">Dashboard</h1><p className="text-gray-400">DriveON platformasi</p></div>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
        {cards.map((c, i) => (
          <motion.div key={c.key} initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.1 }} className="stat-card group">
            <div className="flex items-center justify-between"><span className="text-3xl">{c.icon}</span><div className={`w-12 h-12 rounded-xl bg-gradient-to-br ${c.color} opacity-20 group-hover:opacity-40 transition-opacity`} /></div>
            <p className="text-3xl font-bold text-white mt-2">{stats?.[c.key] ?? 0}</p>
            <p className="text-gray-400 text-sm">{c.label}</p>
          </motion.div>
        ))}
      </div>
      <div className="glass-card-dark overflow-hidden">
        <div className="p-6 border-b border-gray-700/30"><h2 className="text-lg font-semibold text-white">Oxirgi buyurtmalar</h2></div>
        <table className="w-full">
          <thead><tr className="text-gray-400 text-sm border-b border-gray-700/30"><th className="text-left p-4">№</th><th className="text-left p-4">Sarlavha</th><th className="text-left p-4">Holat</th><th className="text-left p-4">Sana</th></tr></thead>
          <tbody>
            {recentOrders.length > 0 ? recentOrders.map((o) => (
              <tr key={o.id} className="table-row">
                <td className="p-4 text-indigo-400 font-mono text-sm">{o.orderNumber}</td>
                <td className="p-4 text-white text-sm">{o.title}</td>
                <td className="p-4"><span className={badge(o.status)}>{o.status}</span></td>
                <td className="p-4 text-gray-500 text-sm">{o.createdAt ? new Date(o.createdAt).toLocaleDateString() : '—'}</td>
              </tr>
            )) : <tr><td colSpan={4} className="p-8 text-center text-gray-500">Buyurtmalar yo'q</td></tr>}
          </tbody>
        </table>
      </div>
    </div>
  );
}
