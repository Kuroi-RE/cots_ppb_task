# Fitur Search & Filter Tugas

## 📋 Deskripsi
Fitur search memungkinkan pengguna untuk mencari dan memfilter tugas berdasarkan berbagai kriteria.

## ✨ Fitur yang Diimplementasikan

### 1. **Search Bar**
- TextField dengan icon search dan clear button
- Placeholder yang informatif
- Auto-clear button ketika ada text
- Real-time search (on-change)

### 2. **Kriteria Pencarian**
Fitur search dapat mencari tugas berdasarkan:
- **Judul tugas** (title)
- **Mata kuliah** (course)
- **Catatan** (note)

### 3. **Kombinasi Filter**
- Search query dapat dikombinasikan dengan filter status
- Filter status: Semua, Berjalan, Selesai, Terlambat
- Hasil ditampilkan sesuai kombinasi filter aktif

### 4. **UI/UX Enhancements**
- Empty state berbeda untuk "tidak ada tugas" vs "tidak ada hasil pencarian"
- Icon yang berbeda (inbox vs search_off)
- Pesan yang kontekstual

## 🔧 Implementasi Teknis

### File yang Dimodifikasi:

1. **task_provider.dart**
   - Menambahkan state `_searchQuery`
   - Method `setSearchQuery()` dan `clearSearch()`
   - Update logika `filteredTasks` untuk mendukung search

2. **task_list_page.dart**
   - Menambahkan `TextEditingController` untuk search
   - UI search bar dengan Material Design
   - Empty state yang dinamis

## 🎯 Cara Menggunakan

1. Buka halaman "Daftar Tugas"
2. Ketik kata kunci di search bar
3. Hasil akan langsung difilter secara real-time
4. Gunakan filter status untuk mempersempit hasil
5. Klik icon X untuk clear pencarian

## 🚀 Contoh Penggunaan

```dart
// Search berdasarkan judul
"Tugas Kalkulus" → akan menemukan tugas dengan title "Tugas Kalkulus"

// Search berdasarkan mata kuliah
"PPB" → akan menemukan semua tugas dari mata kuliah PPB

// Search berdasarkan catatan
"ujian" → akan menemukan tugas yang catatannya mengandung kata "ujian"

// Kombinasi dengan filter
Search: "PPB" + Filter: "BERJALAN" → tugas PPB yang masih berjalan
```

## 📊 Performa
- Case-insensitive search (tidak case-sensitive)
- Efficient filtering menggunakan List.where()
- Real-time update dengan Provider/ChangeNotifier

## 🔮 Pengembangan Lebih Lanjut (Optional)
- [ ] Debouncing untuk mengurangi rebuild saat typing
- [ ] History pencarian
- [ ] Suggestion/autocomplete
- [ ] Advanced filter (by date range, etc.)
- [ ] Sort options (by deadline, title, etc.)
