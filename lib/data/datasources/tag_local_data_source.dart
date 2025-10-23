import 'package:isar/isar.dart';
import '../models/tag_model.dart';

abstract class TagLocalDataSource {
  Future<List<TagModel>> getAllTags();
  Future<TagModel> createTag(TagModel tag);
  Future<void> updateTag(TagModel tag);
  Future<void> deleteTag(int id);
  Future<TagModel?> getTagById(int id);
  Future<List<TagModel>> getTagsByIds(List<int> ids);
  Future<void> incrementTagUsage(int tagId);
  Future<void> decrementTagUsage(int tagId);
  Stream<List<TagModel>> watchAllTags();
}

class TagLocalDataSourceImpl implements TagLocalDataSource {
  final Isar isar;

  TagLocalDataSourceImpl(this.isar);

  @override
  Future<List<TagModel>> getAllTags() async {
    return await isar.tagModels.where().sortByCreatedAtDesc().findAll();
  }

  @override
  Future<TagModel> createTag(TagModel tag) async {
    await isar.writeTxn(() async {
      await isar.tagModels.put(tag);
    });
    return tag;
  }

  @override
  Future<void> updateTag(TagModel tag) async {
    await isar.writeTxn(() async {
      await isar.tagModels.put(tag);
    });
  }

  @override
  Future<void> deleteTag(int id) async {
    await isar.writeTxn(() async {
      await isar.tagModels.delete(id);
    });
  }

  @override
  Future<TagModel?> getTagById(int id) async {
    return await isar.tagModels.get(id);
  }

  @override
  Future<List<TagModel>> getTagsByIds(List<int> ids) async {
    final models = await isar.tagModels.getAll(ids);
    return models.where((model) => model != null).cast<TagModel>().toList();
  }

  @override
  Future<void> incrementTagUsage(int tagId) async {
    final tag = await getTagById(tagId);
    if (tag != null) {
      tag.usageCount++;
      await updateTag(tag);
    }
  }

  @override
  Future<void> decrementTagUsage(int tagId) async {
    final tag = await getTagById(tagId);
    if (tag != null) {
      tag.usageCount = (tag.usageCount - 1).clamp(0, double.infinity).toInt();
      await updateTag(tag);
    }
  }

  /// Watch all tags for changes
  Stream<List<TagModel>> watchAllTags() {
    return isar.tagModels.where().watch(fireImmediately: true);
  }
}
