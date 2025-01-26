import 'package:amplify_core/amplify_core.dart' as amplify_core;
import 'Message.dart';
import 'Plant.dart';

export 'Message.dart';
export 'Plant.dart';

class ModelProvider implements amplify_core.ModelProviderInterface {
  @override
  String version = "0e9cde7f86d73333e2e56b82ad1a5e54";
  @override
  List<amplify_core.ModelSchema> modelSchemas = [Message.schema, Plant.schema];
  @override
  List<amplify_core.ModelSchema> customTypeSchemas = [];
  static final ModelProvider _instance = ModelProvider();

  static ModelProvider get instance => _instance;
  
  amplify_core.ModelType getModelTypeByModelName(String modelName) {
    switch(modelName) {
      case "Message":
        return Message.classType;
      case "Plant":
        return Plant.classType;
      default:
        throw Exception("Failed to find model in model provider for model name: " + modelName);
    }
  }
}


class ModelFieldValue<T> {
  const ModelFieldValue.value(this.value);

  final T value;
}
