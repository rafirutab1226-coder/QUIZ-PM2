import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🏍️ Data produk motor
final productData = {
  'ADV': {'price': 35000000, 'image': 'assets/adv.jpg', 'type': 'matic', 'brand': 'Honda'},
  'Beat': {'price': 18000000, 'image': 'assets/beat.jpg', 'type': 'matic', 'brand': 'Honda'},
  'Supra': {'price': 15000000, 'image': 'assets/supra.jpg', 'type': 'gigi', 'brand': 'Honda'},
  'Vario': {'price': 27000000, 'image': 'assets/vario.jpg', 'type': 'matic', 'brand': 'Honda'},
  'Win': {'price': 15000000, 'image': 'assets/win.jpg', 'type': 'gigi', 'brand': 'Honda'},
  'Aerox': {'price': 28000000, 'image': 'assets/aerox.jpg', 'type': 'matic', 'brand': 'Yamaha'},
  'NMax': {'price': 31000000, 'image': 'assets/nmax.jpg', 'type': 'matic', 'brand': 'Yamaha'},
  'Vixion': {'price': 32000000, 'image': 'assets/vixion.jpg', 'type': 'kopling', 'brand': 'Yamaha'},
  'R15': {'price': 41000000, 'image': 'assets/r15.jpg', 'type': 'kopling', 'brand': 'Yamaha'},
  'GSX': {'price': 29000000, 'image': 'assets/gsx.jpg', 'type': 'kopling', 'brand': 'Suzuki'},
  'Satria': {'price': 26000000, 'image': 'assets/satria.jpg', 'type': 'gigi', 'brand': 'Suzuki'},
  'Scoopy': {'price': 23000000, 'image': 'assets/scoopy.jpg', 'type': 'matic', 'brand': 'Honda'},
  'PCX': {'price': 34000000, 'image': 'assets/pcx.jpg', 'type': 'matic', 'brand': 'Honda'},
  'CBR150R': {'price': 41000000, 'image': 'assets/cbr.jpg', 'type': 'kopling', 'brand': 'Honda'},
  'XSR': {'price': 42000000, 'image': 'assets/xsr.jpg', 'type': 'kopling', 'brand': 'Yamaha'},
};

// 🛒 Provider keranjang
final cartProvider = StateNotifierProvider<CartNotifier, Map<String, int>>((ref) {
  return CartNotifier();
});

// 🔎 Provider filter dan pencarian
final filterProvider = StateProvider<String?>((ref) => null);
final brandProvider = StateProvider<String?>((ref) => null);
final searchProvider = StateProvider<String>((ref) => '');

// 💡 Logika keranjang
class CartNotifier extends StateNotifier<Map<String, int>> {
  CartNotifier()
      : super({
          for (var item in productData.keys) item: 0,
        });

  void increment(String item) {
    state = {...state, item: state[item]! + 1};
  }

  void decrement(String item) {
    if (state[item]! > 0) {
      state = {...state, item: state[item]! - 1};
    }
  }

  void reset() {
    state = {for (final key in state.keys) key: 0};
  }

  int get totalItems => state.values.fold(0, (a, b) => a + b);

  int get totalPrice {
    int total = 0;
    for (var item in state.keys) {
      total += state[item]! * (productData[item]!['price'] as int);
    }
    return total;
  }
}

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce Motor Riverpod',
      theme: ThemeData(primarySwatch: Colors.teal),
      debugShowCheckedModeBanner: false,
      home: const CartPage(),
    );
  }
}

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final totalItems = cartNotifier.totalItems;
    final totalPrice = cartNotifier.totalPrice;

    final selectedType = ref.watch(filterProvider);
    final selectedBrand = ref.watch(brandProvider);
    final searchText = ref.watch(searchProvider);

    // Filter produk
    final filteredProducts = productData.entries.where((e) {
      final matchesType = selectedType == null || e.value['type'] == selectedType;
      final matchesBrand = selectedBrand == null || e.value['brand'] == selectedBrand;
      final matchesSearch = e.key.toLowerCase().contains(searchText.toLowerCase());
      return matchesType && matchesBrand && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('🛵 Motor Shop ($totalItems barang)'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // 🔍 Filter
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                DropdownButton<String>(
                  hint: const Text('Filter Jenis'),
                  value: selectedType,
                  onChanged: (value) => ref.read(filterProvider.notifier).state = value,
                  items: const [
                    DropdownMenuItem(value: 'matic', child: Text('Matic')),
                    DropdownMenuItem(value: 'gigi', child: Text('Gigi')),
                    DropdownMenuItem(value: 'kopling', child: Text('Kopling')),
                  ],
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  hint: const Text('Filter Merek'),
                  value: selectedBrand,
                  onChanged: (value) => ref.read(brandProvider.notifier).state = value,
                  items: const [
                    DropdownMenuItem(value: 'Honda', child: Text('Honda')),
                    DropdownMenuItem(value: 'Yamaha', child: Text('Yamaha')),
                    DropdownMenuItem(value: 'Suzuki', child: Text('Suzuki')),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Cari nama motor...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onChanged: (value) => ref.read(searchProvider.notifier).state = value,
                  ),
                ),
              ],
            ),
          ),
          // 🏍️ Daftar motor
          Expanded(
            child: ListView(
              children: filteredProducts.map((entry) {
                final item = entry.key;
                final data = entry.value;
                final qty = cart[item]!;
                final price = data['price'] as int;
                final image = data['image'] as String;
                final subtotal = qty * price;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  elevation: 3,
                  child: ListTile(
                    leading: Image.asset(image, width: 50, height: 50),
                    title: Text(item, style: const TextStyle(fontSize: 20)),
                    subtitle: Text('${data['brand']} | ${data['type']} | Rp$price'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => cartNotifier.decrement(item),
                        ),
                        Text('$qty', style: const TextStyle(fontSize: 18)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            cartNotifier.increment(item);
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('🧾 Nota Pembelian'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.asset(image, width: 100, height: 100),
                                    const SizedBox(height: 8),
                                    Text('Nama Motor: $item'),
                                    Text('Merek: ${data['brand']}'),
                                    Text('Jenis: ${data['type']}'),
                                    Text('Harga Satuan: Rp$price'),
                                    Text('Jumlah: ${qty + 1}'),
                                    Text('Subtotal: Rp${(qty + 1) * price}'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Tutup'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Rp$subtotal',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // 💰 Total dan tombol aksi
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              border: const Border(top: BorderSide(color: Colors.teal, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Total Harga: Rp$totalPrice',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Checkout berhasil! Terima kasih 🛍️'),
                            ),
                          );
                          cartNotifier.reset();
                        },
                        icon: const Icon(Icons.payment),
                        label: const Text('Checkout'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: cartNotifier.reset,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
