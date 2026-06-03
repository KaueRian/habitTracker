import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/leve_theme.dart';
import 'habit_provider.dart';
import '../settings/preferences_provider.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  final Habit? habit; // If passed, we are editing

  const AddHabitScreen({super.key, this.habit});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _habitName;
  late String _selectedCategory;
  bool _isCustom = true;

  // Categories list
  final List<String> _categories = [
    'movimento',
    'mental',
    'nutrição',
    'hidratação',
    'sono',
    'social',
    'financeiro',
    'espiritual',
  ];

  // Pre-defined habit library templates grouped by identity
  List<Map<String, String>> _getHabitLibrary(String identity) {
    switch (identity.toLowerCase()) {
      case 'bem-estar silencioso':
        return [
          {'name': '10 minutos de meditação', 'category': 'mental'},
          {'name': 'escrever no diário', 'category': 'mental'},
          {'name': 'exercício de respiração calma', 'category': 'mental'},
          {'name': 'passar 5 min em silêncio', 'category': 'mental'},
          {'name': 'desconectar do celular à noite', 'category': 'sono'},
          {'name': 'fazer auto-massagem', 'category': 'mental'},
          {'name': 'ouvir sons da natureza', 'category': 'mental'},
          {'name': 'caminhada meditativa', 'category': 'movimento'},
        ];
      case 'protagonista':
        return [
          {'name': 'treino na academia', 'category': 'movimento'},
          {'name': 'planejar o dia seguinte', 'category': 'mental'},
          {'name': 'beber 3L de água', 'category': 'hidratação'},
          {'name': 'aprender algo novo (15 min)', 'category': 'mental'},
          {'name': 'arrumar a cama ao acordar', 'category': 'mental'},
          {'name': 'leitura de autodesenvolvimento', 'category': 'mental'},
          {'name': 'registrar metas semanais', 'category': 'financeiro'},
          {'name': 'vestir roupa que traz confiança', 'category': 'social'},
        ];
      case 'vida desacelerada':
        return [
          {'name': 'tomar café sem pressa', 'category': 'nutrição'},
          {'name': 'observar o pôr do sol/natureza', 'category': 'mental'},
          {'name': 'ler um livro (10 páginas)', 'category': 'mental'},
          {'name': 'regar as plantas / cuidar do jardim', 'category': 'espiritual'},
          {'name': 'preparar um chá com calma', 'category': 'nutrição'},
          {'name': 'dar um passeio sem rumo', 'category': 'movimento'},
          {'name': 'escrever uma mensagem a alguém especial', 'category': 'social'},
          {'name': 'fazer uma pausa de 10 min à tarde', 'category': 'sono'},
        ];
      case 'saúde suave':
      default:
        return [
          {'name': 'beber água ao acordar', 'category': 'hidratação'},
          {'name': 'beber 2L de água no dia', 'category': 'hidratação'},
          {'name': 'caminhada leve de 20 min', 'category': 'movimento'},
          {'name': 'comer uma porção de frutas', 'category': 'nutrição'},
          {'name': 'alongamento matinal leve', 'category': 'movimento'},
          {'name': 'dormir pelo menos 7-8 horas', 'category': 'sono'},
          {'name': 'chá morno sem açúcar à noite', 'category': 'nutrição'},
          {'name': 'ouvir o próprio corpo (pausa rápida)', 'category': 'mental'},
        ];
    }
  }

  @override
  void initState() {
    super.initState();
    _habitName = widget.habit?.name ?? '';
    _selectedCategory = widget.habit?.category ?? 'mental';
    _isCustom = widget.habit != null;
  }

  void _save() {
    if (_isCustom) {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        if (widget.habit == null) {
          final success = ref.read(habitProvider.notifier).addHabit(_habitName, _selectedCategory);
          if (!success) {
            _showLimitReachedSnackbar();
            return;
          }
        } else {
          ref.read(habitProvider.notifier).editHabit(widget.habit!.id, _habitName, _selectedCategory);
        }
        Navigator.pop(context);
      }
    } else {
      // Library save
      if (_habitName.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione um hábito da biblioteca ou crie um personalizado.')),
        );
        return;
      }
      final success = ref.read(habitProvider.notifier).addHabit(_habitName, _selectedCategory);
      if (!success) {
        _showLimitReachedSnackbar();
        return;
      }
      Navigator.pop(context);
    }
  }

  void _showLimitReachedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Limite de 4 hábitos atingido. Assine o Leve+ para hábitos ilimitados!'),
        backgroundColor: LeveTheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habit != null;
    final identity = ref.watch(identityProvider);
    final habitLibrary = _getHabitLibrary(identity);

    return Scaffold(
      backgroundColor: LeveTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'cancelar',
            style: GoogleFonts.inter(color: LeveTheme.textSecondary, fontSize: 14),
          ),
        ),
        leadingWidth: 80,
        title: Text(
          isEditing ? 'editar hábito' : 'novo hábito',
          style: GoogleFonts.dmSerifDisplay(fontSize: 20, color: LeveTheme.textPrimary),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              'salvar',
              style: GoogleFonts.inter(color: LeveTheme.primary, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isEditing) ...[
                // Mode Toggle Row (Library / Custom)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isCustom = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: !_isCustom ? LeveTheme.background : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'da biblioteca',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: !_isCustom ? FontWeight.bold : FontWeight.normal,
                                color: LeveTheme.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isCustom = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _isCustom ? LeveTheme.background : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'personalizado',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: _isCustom ? FontWeight.bold : FontWeight.normal,
                                color: LeveTheme.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              if (_isCustom) ...[
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NOME DO HÁBITO',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: LeveTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: _habitName,
                        style: GoogleFonts.inter(color: LeveTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'ex: ler antes de dormir',
                          hintStyle: GoogleFonts.inter(color: LeveTheme.textLight),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, insira o nome do hábito.';
                          }
                          return null;
                        },
                        onSaved: (value) => _habitName = value!.trim(),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'CATEGORIA',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: LeveTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return ChoiceChip(
                            label: Text(
                              cat,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: LeveTheme.primary.withValues(alpha: 0.2),
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: isSelected ? LeveTheme.primary : Colors.transparent,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedCategory = cat);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Library Listing Screen
                Text(
                  'RECOMENDADOS PARA VOCÊ',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: LeveTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: habitLibrary.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = habitLibrary[index];
                    final isSelected = _habitName == item['name'];
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      tileColor: isSelected ? LeveTheme.primary.withValues(alpha: 0.1) : Colors.white,
                      title: Text(
                        item['name']!,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: LeveTheme.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        item['category']!,
                        style: GoogleFonts.inter(fontSize: 11, color: LeveTheme.textSecondary),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: LeveTheme.primary)
                          : const Icon(Icons.add_circle_outline, color: LeveTheme.textLight),
                      onTap: () {
                        setState(() {
                          _habitName = item['name']!;
                          _selectedCategory = item['category']!;
                        });
                      },
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
