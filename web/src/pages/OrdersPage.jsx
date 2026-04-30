import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import api from '../api/client';

export default function OrdersPage() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(0);
  const [totalPages, setTotalPages] = useState(0);
  const [showModal, setShowModal] = useState(false);
  const [form, setForm] = useState({ title:'', description:'', pickupAddress:'', deliveryAddress:'', price:'' });

  useEffect(() => { loadOrders(); }, [page]);

  const loadOrders = async () => {
    setLoading(true);
    try {
      const data = await api.getOrders(page, 10);
      setOrders(data.content || []);
      setTotalPages(data.totalPages || 0);
    } catch (e) { console.error(e); } finally { setLoading(false); }
  };

  const handleCreate = async (e) => {
    e.preventDefault();
    try {
      await api.createOrder({ ...form, price: form.price ? parseFloat(form.price) : null });
      setShowModal(false);
      setForm({ title:'', description:'', pickupAddress:'', deliveryAddress:'', price:'' });
      loadOrders();
    } catch (e) { alert(e.message); }
  };

  const badge = (s) => {
    const m = { PENDING:'badge-pending', DELIVERED:'badge-delivered', CANCELLED:'badge-cancelled' };
    return m[s] || 'badge-active';
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div><h1 className="text-2xl font-bold text-white">Buyurtmalar</h1><p className="text-gray-400 text-sm">Barcha buyurtmalar ro'yxati</p></div>
        <button onClick={() => setShowModal(true)} className="btn-primary">+ Yangi buyurtma</button>
      </div>

      <div className="glass-card-dark overflow-hidden">
        {loading ? (
          <div className="flex items-center justify-center h-40"><div className="w-8 h-8 border-4 border-indigo-500 border-t-transparent rounded-full animate-spin" /></div>
        ) : (
          <table className="w-full">
            <thead><tr className="text-gray-400 text-sm border-b border-gray-700/30">
              <th className="text-left p-4">№</th><th className="text-left p-4">Sarlavha</th><th className="text-left p-4">Olib ketish</th><th className="text-left p-4">Yetkazish</th><th className="text-left p-4">Narx</th><th className="text-left p-4">Holat</th>
            </tr></thead>
            <tbody>
              {orders.map(o => (
                <tr key={o.id} className="table-row">
                  <td className="p-4 text-indigo-400 font-mono text-sm">{o.orderNumber}</td>
                  <td className="p-4 text-white text-sm">{o.title}</td>
                  <td className="p-4 text-gray-400 text-sm truncate max-w-[150px]">{o.pickupAddress}</td>
                  <td className="p-4 text-gray-400 text-sm truncate max-w-[150px]">{o.deliveryAddress}</td>
                  <td className="p-4 text-white text-sm">{o.price ? `${o.price} so'm` : '—'}</td>
                  <td className="p-4"><span className={badge(o.status)}>{o.status}</span></td>
                </tr>
              ))}
              {orders.length === 0 && <tr><td colSpan={6} className="p-8 text-center text-gray-500">Buyurtmalar yo'q</td></tr>}
            </tbody>
          </table>
        )}
        {totalPages > 1 && (
          <div className="flex items-center justify-center gap-2 p-4 border-t border-gray-700/30">
            <button onClick={() => setPage(p => Math.max(0, p-1))} disabled={page===0} className="btn-secondary text-sm px-3 py-1.5 disabled:opacity-30">← Oldingi</button>
            <span className="text-gray-400 text-sm">{page+1} / {totalPages}</span>
            <button onClick={() => setPage(p => Math.min(totalPages-1, p+1))} disabled={page>=totalPages-1} className="btn-secondary text-sm px-3 py-1.5 disabled:opacity-30">Keyingi →</button>
          </div>
        )}
      </div>

      {/* Create Modal */}
      {showModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm" onClick={() => setShowModal(false)}>
          <motion.div initial={{ opacity:0, scale:0.95 }} animate={{ opacity:1, scale:1 }} className="glass-card-dark p-8 w-full max-w-lg mx-4" onClick={e => e.stopPropagation()}>
            <h2 className="text-xl font-bold text-white mb-6">Yangi buyurtma</h2>
            <form onSubmit={handleCreate} className="space-y-4">
              <input className="input-field" placeholder="Sarlavha" value={form.title} onChange={e => setForm({...form, title:e.target.value})} required />
              <input className="input-field" placeholder="Tavsif" value={form.description} onChange={e => setForm({...form, description:e.target.value})} />
              <input className="input-field" placeholder="Olib ketish manzili" value={form.pickupAddress} onChange={e => setForm({...form, pickupAddress:e.target.value})} required />
              <input className="input-field" placeholder="Yetkazish manzili" value={form.deliveryAddress} onChange={e => setForm({...form, deliveryAddress:e.target.value})} required />
              <input type="number" className="input-field" placeholder="Narx (so'm)" value={form.price} onChange={e => setForm({...form, price:e.target.value})} />
              <div className="flex gap-3 pt-2">
                <button type="button" onClick={() => setShowModal(false)} className="btn-secondary flex-1">Bekor</button>
                <button type="submit" className="btn-primary flex-1">Yaratish</button>
              </div>
            </form>
          </motion.div>
        </div>
      )}
    </div>
  );
}
