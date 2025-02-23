import { useSupabaseClient } from '#imports';

export async function useUserRole() {
    const supabase = useSupabaseClient();

    // Ambil user yang sedang login
    const { data: user, error: userError } = await supabase.auth.getUser();
    if (userError || !user?.user) return 'guest';

    // Query ke tabel users berdasarkan ID
    const { data, error } = await supabase
        .from('users')
        .select('role')
        .eq('id', user.user.id)
        .single();

    if (error) {
        console.error('Error fetching role:', error);
        return 'user'; // Default ke 'guest' jika gagal
    }

    return data?.role || 'user';
}
