import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/character_provider.dart';

class NameInputWidget extends ConsumerStatefulWidget {
  const NameInputWidget({super.key});

  @override
  ConsumerState<NameInputWidget> createState() => _NameInputWidgetState();
}

class _NameInputWidgetState extends ConsumerState<NameInputWidget> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(characterCreationProvider);
    _controller.text = state.name;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '🗡️ What is your name, hero? 🗡️',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Character Name',
                      hintText: 'Enter your hero\'s name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    maxLength: 50,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (value) {
                      ref.read(characterCreationProvider.notifier).setName(value);
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a memorable name for your hero. This will be how others refer to you on your journey.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
