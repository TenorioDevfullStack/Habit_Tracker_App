import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gamification_provider.dart';

class ThemeStoreScreen extends StatefulWidget {
  const ThemeStoreScreen({super.key});

  @override
  State<ThemeStoreScreen> createState() => _ThemeStoreScreenState();
}

class _ThemeStoreScreenState extends State<ThemeStoreScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏪 Loja de Temas'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        actions: [
          Consumer<GamificationProvider>(
            builder: (context, provider, child) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${provider.userProfile.coins}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Theme.of(context).appBarTheme.foregroundColor,
          unselectedLabelColor: Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.7),
          tabs: const [
            Tab(icon: Icon(Icons.palette), text: 'Temas'),
            Tab(icon: Icon(Icons.account_circle), text: 'Avatares'),
            Tab(icon: Icon(Icons.auto_awesome), text: 'Efeitos'),
          ],
        ),
      ),
      body: Consumer<GamificationProvider>(
        builder: (context, provider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildThemesTab(provider),
              _buildAvatarsTab(provider),
              _buildEffectsTab(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemesTab(GamificationProvider provider) {
    final themes = provider.availableThemes;
    final currentTheme = provider.userProfile.currentTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Filtros por categoria
        _buildCategoryFilter(themes),
        
        const SizedBox(height: 16),
        
        // Lista de temas
        ...themes.where((theme) {
          if (_selectedCategory == 'all') return true;
          return theme['category'] == _selectedCategory;
        }).map((theme) => _buildThemeCard(theme, provider, currentTheme)),
      ],
    );
  }

  Widget _buildAvatarsTab(GamificationProvider provider) {
    final avatars = provider.availableAvatars.where((a) => a['type'] == 'frame').toList();
    final currentFrame = provider.userProfile.currentAvatarFrame;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Molduras de Avatar',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: avatars.length,
          itemBuilder: (context, index) {
            final avatar = avatars[index];
            return _buildAvatarCard(avatar, provider, currentFrame);
          },
        ),
      ],
    );
  }

  Widget _buildEffectsTab(GamificationProvider provider) {
    final effects = provider.availableAvatars.where((a) => a['type'] == 'effect').toList();
    final currentEffect = provider.userProfile.currentAvatarEffect;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Efeitos Especiais',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: effects.length,
          itemBuilder: (context, index) {
            final effect = effects[index];
            return _buildEffectCard(effect, provider, currentEffect);
          },
        ),
      ],
    );
  }

  Widget _buildCategoryFilter(List<Map<String, dynamic>> themes) {
    final categories = {
      'all': {'name': 'Todos', 'icon': Icons.all_inclusive},
      'basic': {'name': 'Básico', 'icon': Icons.star_border},
      'premium': {'name': 'Premium', 'icon': Icons.star},
      'epic': {'name': 'Épico', 'icon': Icons.auto_awesome},
      'legendary': {'name': 'Lendário', 'icon': Icons.diamond},
    };

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final categoryKey = categories.keys.elementAt(index);
          final category = categories[categoryKey]!;
          final isSelected = _selectedCategory == categoryKey;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 18,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(category['name'] as String),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = categoryKey;
                });
              },
              selectedColor: Colors.blue,
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeCard(Map<String, dynamic> theme, GamificationProvider provider, String currentTheme) {
    final isUnlocked = theme['unlocked'] as bool;
    final isCurrent = theme['id'] == currentTheme;
    final price = theme['price'] as int;
    final userCoins = provider.userProfile.coins;
    final canAfford = userCoins >= price;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: isCurrent ? 8 : 2,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isCurrent 
                ? Border.all(color: Colors.blue, width: 3)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Preview do tema
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: (theme['gradient'] as List<dynamic>)
                              .map((color) => Color(color as int))
                              .toList(),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: isCurrent
                          ? const Icon(Icons.check, color: Colors.white, size: 24)
                          : null,
                    ),
                    
                    const SizedBox(width: 16),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                theme['name'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildCategoryBadge(theme['category']),
                            ],
                          ),
                          Text(
                            theme['description'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          if (price > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '$price moedas',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: canAfford ? Colors.amber : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Botões de ação
                Row(
                  children: [
                    if (isCurrent) ...[
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Em Uso',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else if (isUnlocked) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _equipTheme(theme['id'], provider),
                          icon: const Icon(Icons.palette),
                          label: const Text('Equipar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: canAfford 
                              ? () => _purchaseTheme(theme, provider)
                              : null,
                          icon: Icon(canAfford ? Icons.shopping_cart : Icons.lock),
                          label: Text(canAfford ? 'Comprar' : 'Sem moedas'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canAfford ? Colors.green : Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _previewTheme(theme),
                      child: const Icon(Icons.visibility),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarCard(Map<String, dynamic> avatar, GamificationProvider provider, String currentFrame) {
    final isUnlocked = avatar['unlocked'] as bool;
    final isCurrent = avatar['id'] == currentFrame;
    final price = avatar['price'] as int;
    final userCoins = provider.userProfile.coins;
    final canAfford = userCoins >= price;

    return Card(
      elevation: isCurrent ? 6 : 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isCurrent 
              ? Border.all(color: Colors.blue, width: 2)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Preview do avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  border: _getAvatarBorder(avatar['effect']),
                ),
                child: Center(
                  child: Text(
                    provider.userProfile.levelEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                avatar['name'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              if (price > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.monetization_on, color: Colors.amber, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      '$price',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: canAfford ? Colors.amber : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 8),
              
              // Botão de ação
              if (isCurrent) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Em Uso',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ] else if (isUnlocked) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _equipAvatar(avatar['id'], provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                    child: const Text('Equipar', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canAfford 
                        ? () => _purchaseAvatar(avatar, provider)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canAfford ? Colors.green : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                    child: Text(
                      canAfford ? 'Comprar' : 'Sem moedas',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEffectCard(Map<String, dynamic> effect, GamificationProvider provider, String currentEffect) {
    // Similar ao _buildAvatarCard mas para efeitos
    final isUnlocked = effect['unlocked'] as bool;
    final isCurrent = effect['id'] == currentEffect;
    final price = effect['price'] as int;
    final userCoins = provider.userProfile.coins;
    final canAfford = userCoins >= price;

    return Card(
      elevation: isCurrent ? 6 : 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isCurrent 
              ? Border.all(color: Colors.purple, width: 2)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Preview do efeito
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.purple.shade600],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getEffectIcon(effect['effect']),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                effect['name'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              if (price > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.monetization_on, color: Colors.amber, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      '$price',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: canAfford ? Colors.amber : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 8),
              
              // Botão de ação (similar ao avatar)
              if (isCurrent) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Ativo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ] else if (isUnlocked) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _equipAvatar(effect['id'], provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                    child: const Text('Ativar', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canAfford 
                        ? () => _purchaseAvatar(effect, provider)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canAfford ? Colors.green : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                    child: Text(
                      canAfford ? 'Comprar' : 'Sem moedas',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    final colors = {
      'basic': Colors.grey,
      'premium': Colors.blue,
      'epic': Colors.purple,
      'legendary': Colors.amber,
    };

    final icons = {
      'basic': Icons.star_border,
      'premium': Icons.star,
      'epic': Icons.auto_awesome,
      'legendary': Icons.diamond,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colors[category]?.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors[category] ?? Colors.grey),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icons[category] ?? Icons.star,
            size: 12,
            color: colors[category],
          ),
          const SizedBox(width: 2),
          Text(
            category.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: colors[category],
            ),
          ),
        ],
      ),
    );
  }

  Border? _getAvatarBorder(String effect) {
    switch (effect) {
      case 'golden_border':
        return Border.all(color: Colors.amber, width: 3);
      case 'silver_border':
        return Border.all(color: Colors.grey.shade400, width: 3);
      case 'rainbow_border':
        return Border.all(color: Colors.purple, width: 3);
      default:
        return null;
    }
  }

  IconData _getEffectIcon(String effect) {
    switch (effect) {
      case 'neon_glow':
        return Icons.blur_on;
      case 'pulse':
        return Icons.favorite;
      case 'fire_animation':
        return Icons.local_fire_department;
      default:
        return Icons.auto_awesome;
    }
  }

  void _equipTheme(String themeId, GamificationProvider provider) {
    provider.changeTheme(themeId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Tema equipado com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _equipAvatar(String avatarId, GamificationProvider provider) {
    provider.equipAvatar(avatarId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Item equipado com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _purchaseTheme(Map<String, dynamic> theme, GamificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('💰 Comprar ${theme['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Deseja comprar este tema por ${theme['price']} moedas?'),
            const SizedBox(height: 8),
            Text('Moedas atuais: ${provider.userProfile.coins}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.purchaseTheme(theme['id']);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🎉 Tema comprado com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Moedas insuficientes!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Comprar'),
          ),
        ],
      ),
    );
  }

  void _purchaseAvatar(Map<String, dynamic> avatar, GamificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('💰 Comprar ${avatar['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Deseja comprar este item por ${avatar['price']} moedas?'),
            const SizedBox(height: 8),
            Text('Moedas atuais: ${provider.userProfile.coins}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.purchaseAvatar(avatar['id']);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🎉 Item comprado com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Moedas insuficientes!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Comprar'),
          ),
        ],
      ),
    );
  }

  void _previewTheme(Map<String, dynamic> theme) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: (theme['gradient'] as List<dynamic>)
                  .map((color) => Color(color as int))
                  .toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                theme['name'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                theme['description'],
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                ),
                child: const Text('Fechar Preview'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 