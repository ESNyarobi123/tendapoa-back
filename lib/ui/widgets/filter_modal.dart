import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/constants.dart';
import '../../providers/providers.dart';

class FilterModal extends StatefulWidget {
  const FilterModal({super.key});

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  String? _selectedCategory;
  double _distance = 10.0;

  @override
  void initState() {
    super.initState();
    final provider = context.read<WorkerProvider>();
    _selectedCategory = provider.selectedCategory;
    _distance = provider.selectedDistance ?? 10.0;
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<AppProvider>().categories;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Chuja Kazi (Filters)',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: Color(0xFF1E293B))),
              TextButton(
                onPressed: () {
                  context.read<WorkerProvider>().clearFilters();
                  Navigator.pop(context);
                },
                child: const Text('Clear All',
                    style: TextStyle(
                        color: AppColors.error, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Text('Kategoria',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                bool isSelected = _selectedCategory == cat.name;
                return GestureDetector(
                  onTap: () => setState(
                      () => _selectedCategory = isSelected ? null : cat.name),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(cat.name,
                          style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Umbali (Radius)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${_distance.toInt()} KM',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 10),
          Slider(
            value: _distance,
            min: 1,
            max: 50,
            divisions: 49,
            activeColor: AppColors.primary,
            inactiveColor: const Color(0xFFF1F5F9),
            onChanged: (v) => setState(() => _distance = v),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<WorkerProvider>().loadJobsFeed(
                      category: _selectedCategory,
                      distance: _distance,
                    );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: const Text('ONYESHA KAZI',
                  style:
                      TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
