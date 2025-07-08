import 'package:mobx/mobx.dart';

// Gera o código automaticamente
part 'counter_store.g.dart';

class CounterStore = _CounterStoreBase with _$CounterStore;

abstract class _CounterStoreBase with Store {
  // Defina o estado observável
  @observable
  int counter = 0;

  // Defina as ações
  @action
  void increment() {
    counter++;
  }

  @action
  void decrement() {
    counter--;
  }
}
