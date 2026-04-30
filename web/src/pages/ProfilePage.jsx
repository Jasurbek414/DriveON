import useAuthStore from '../store/useAuthStore';

export default function ProfilePage() {
  const { user } = useAuthStore();

  return (
    <div className="space-y-6 max-w-2xl">
      <div><h1 className="text-2xl font-bold text-white">Profil</h1><p className="text-gray-400 text-sm">Shaxsiy ma'lumotlar</p></div>
      <div className="glass-card-dark p-8">
        <div className="flex items-center gap-6 mb-8">
          <div className="w-20 h-20 rounded-2xl bg-gradient-to-br from-indigo-500 to-purple-500 flex items-center justify-center text-white font-bold text-2xl shadow-glow-sm">
            {user?.fullName?.charAt(0) || 'U'}
          </div>
          <div>
            <h2 className="text-xl font-bold text-white">{user?.fullName || 'User'}</h2>
            <p className="text-gray-400 text-sm">@{user?.username}</p>
            <div className="flex gap-2 mt-2">
              {user?.roles?.map(r => <span key={r} className="badge bg-indigo-500/20 text-indigo-400">{r.replace('ROLE_','')}</span>)}
            </div>
          </div>
        </div>
        <div className="space-y-4">
          {[
            ['Email', user?.email],
            ['Telefon', user?.phoneNumber || 'Ko\'rsatilmagan'],
            ['Holat', user?.active ? '✅ Faol' : '❌ Nofaol'],
            ['Ro\'yxatdan o\'tgan', user?.createdAt ? new Date(user.createdAt).toLocaleDateString() : '—'],
          ].map(([label, value]) => (
            <div key={label} className="flex items-center justify-between py-3 border-b border-gray-700/20">
              <span className="text-gray-400 text-sm">{label}</span>
              <span className="text-white text-sm font-medium">{value}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
