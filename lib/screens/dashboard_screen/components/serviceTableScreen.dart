import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dz_admin_panel/service/cloudinary_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  bool loading = true;

  List<Category> categories = [];
  List<Service> services = [];

  @override
  void initState() {
    super.initState();
    _fetchCategoriesAndServices();
  }

  Future<void> _fetchCategoriesAndServices() async {
    // Fetch categories
    final categoriesSnapshot =
        await FirebaseFirestore.instance.collection('categories').get();

    final fetchedCategories =
        categoriesSnapshot.docs.map((doc) {
          final data = doc.data();
          return Category(
            id: doc.id,
            imageUrl: data['imageUrl'] ?? '',
            title: data['title'] ?? '',
            isActive: data['isActive'] ?? true,
          );
        }).toList();

    // Fetch services
    final servicesSnapshot =
        await FirebaseFirestore.instance.collection('services').get();

    double parsePrice(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val is String) {
        return double.tryParse(val) ?? 0.0;
      }
      return 0.0;
    }

    final fetchedServices =
        servicesSnapshot.docs.map((doc) {
          final data = doc.data();
          return Service(
            id: doc.id,
            categoryId: data['category'] ?? '',
            name: data['name'] ?? '',
            price: parsePrice(data['price']),
            onVisit: data['onVisit'] ?? false,
            isFeatured: data['isFeatured'] ?? false,
            isActive: data['isActive'] ?? true,
          );
        }).toList();

    setState(() {
      categories = fetchedCategories;
      services = fetchedServices;
      loading = false;
    });
  }

  Future<void> _toggleCategoryActive(String id, bool newStatus) async {
    await FirebaseFirestore.instance.collection('categories').doc(id).update({
      'isActive': newStatus,
    });
    setState(() {
      categories =
          categories.map((cat) {
            if (cat.id == id) return cat.copyWith(isActive: newStatus);
            return cat;
          }).toList();
    });
  }

  Future<void> _toggleServiceActive(String id, bool newStatus) async {
    await FirebaseFirestore.instance.collection('services').doc(id).update({
      'isActive': newStatus,
    });
    setState(() {
      services =
          services.map((srv) {
            if (srv.id == id) return srv.copyWith(isActive: newStatus);
            return srv;
          }).toList();
    });
  }

  Future<void> _toggleServiceFeatured(String id, bool newStatus) async {
    await FirebaseFirestore.instance.collection('services').doc(id).update({
      'isFeatured': newStatus,
    });
    setState(() {
      services =
          services.map((srv) {
            if (srv.id == id) return srv.copyWith(isFeatured: newStatus);
            return srv;
          }).toList();
    });
  }

  String _getCategoryTitle(String categoryId) {
    final cat = categories.firstWhere(
      (c) => c.id == categoryId,
      orElse:
          () =>
              Category(id: '', title: 'Unknown', imageUrl: '', isActive: false),
    );
    return cat.title;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Services & Categories')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    return Scaffold(
      appBar: AppBar(title: const Text('Services & Categories')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildCategoriesTable(),
              const SizedBox(height: 32),
              _buildServicesTable(),
            ],
          ),
        ),
      ),
    );
  }

  // Future<void> _showEditCategoryDialog(Category category) async {
  //   final TextEditingController titleController = TextEditingController(
  //     text: category.title,
  //   );
  //   String imageUrl = category.imageUrl;

  //   await showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('Edit Category'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             imageUrl.isNotEmpty
  //                 ? Image.network(imageUrl, height: 100)
  //                 : const Icon(Icons.image),
  //             const SizedBox(height: 10),
  //             TextField(
  //               controller: titleController,
  //               decoration: const InputDecoration(labelText: 'Title'),
  //             ),
  //             const SizedBox(height: 10),
  //             ElevatedButton.icon(
  //               icon: const Icon(Icons.image),
  //               label: const Text('Pick New Image'),
  //               onPressed: () async {
  //                 // Placeholder: You should integrate image picking/upload here
  //                 // For demo, let's fake new image URL
  //                 setState(() {
  //                   imageUrl =
  //                       'https://via.placeholder.com/100'; // simulate upload
  //                 });
  //               },
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text('Cancel'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () async {
  //               await FirebaseFirestore.instance
  //                   .collection('categories')
  //                   .doc(category.id)
  //                   .update({
  //                     'title': titleController.text,
  //                     'imageUrl': imageUrl,
  //                   });

  //               setState(() {
  //                 categories =
  //                     categories.map((cat) {
  //                       if (cat.id == category.id) {
  //                         return Category(
  //                           id: cat.id,
  //                           imageUrl: imageUrl,
  //                           title: titleController.text,
  //                           isActive: cat.isActive,
  //                         );
  //                       }
  //                       return cat;
  //                     }).toList();
  //               });

  //               Navigator.pop(context);
  //             },
  //             child: const Text('Save'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<void> _showDeleteCategoryDialog(Category category) async {
    final affectedServices =
        services.where((s) => s.categoryId == category.id).toList();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Category?'),
          content: Text(
            'If you delete this category, ${affectedServices.length} services linked to it will be deactivated.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(category.id)
          .delete();

      // Deactivate linked services
      for (final srv in affectedServices) {
        await FirebaseFirestore.instance
            .collection('services')
            .doc(srv.id)
            .update({'isActive': false});
      }

      setState(() {
        categories.removeWhere((c) => c.id == category.id);
        services =
            services.map((srv) {
              if (srv.categoryId == category.id) {
                return srv.copyWith(isActive: false);
              }
              return srv;
            }).toList();
      });
    }
  }

  // Future<void> _showAddCategoryDialog() async {
  //   final titleController = TextEditingController();
  //   File? pickedImage;
  //   final ImagePicker picker = ImagePicker();
  //   bool isUploading = false;

  //   await showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return AlertDialog(
  //             title: const Text('Add Category'),
  //             content: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 TextField(
  //                   controller: titleController,
  //                   decoration: const InputDecoration(labelText: 'Title'),
  //                 ),
  //                 const SizedBox(height: 10),
  //                 pickedImage == null
  //                     ? ElevatedButton.icon(
  //                       icon: const Icon(Icons.image),
  //                       label: const Text('Pick Image'),
  //                       onPressed: () async {
  //                         final XFile? image = await picker.pickImage(
  //                           source: ImageSource.gallery,
  //                         );
  //                         if (image != null) {
  //                           setState(() {
  //                             pickedImage = File(image.path);
  //                           });
  //                         }
  //                       },
  //                     )
  //                     : Image.file(pickedImage!, height: 100),
  //                 if (isUploading) ...[
  //                   const SizedBox(height: 10),
  //                   const CircularProgressIndicator(),
  //                 ],
  //               ],
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.pop(context),
  //                 child: const Text('Cancel'),
  //               ),
  //               ElevatedButton(
  //                 onPressed: () async {
  //                   if (pickedImage == null ||
  //                       titleController.text.trim().isEmpty) {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       const SnackBar(
  //                         content: Text('Please provide title and image'),
  //                       ),
  //                     );
  //                     return;
  //                   }

  //                   setState(() => isUploading = true);

  //                   final imageUrl = await uploadImageToCloudinary(
  //                     pickedImage!,
  //                   );

  //                   setState(() => isUploading = false);

  //                   if (imageUrl == null) {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       const SnackBar(content: Text('Image upload failed')),
  //                     );
  //                     return;
  //                   }

  //                   final doc = await FirebaseFirestore.instance
  //                       .collection('categories')
  //                       .add({
  //                         'title': titleController.text.trim(),
  //                         'imageUrl': imageUrl,
  //                         'isActive': true,
  //                       });

  //                   setState(() {
  //                     categories.add(
  //                       Category(
  //                         id: doc.id,
  //                         imageUrl: imageUrl,
  //                         title: titleController.text.trim(),
  //                         isActive: true,
  //                       ),
  //                     );
  //                   });

  //                   Navigator.pop(context);
  //                 },
  //                 child: const Text('Add'),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  Future<void> _showAddCategoryDialog() async {
    final titleController = TextEditingController();
    Uint8List? pickedImageBytes;
    bool isUploading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 10),
                  pickedImageBytes == null
                      ? ElevatedButton.icon(
                        icon: const Icon(Icons.image),
                        label: const Text('Pick Image'),
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.image,
                            allowMultiple: false,
                          );
                          if (result != null &&
                              result.files.single.bytes != null) {
                            setState(() {
                              pickedImageBytes = result.files.single.bytes!;
                            });
                          }
                        },
                      )
                      : Image.memory(pickedImageBytes!, height: 100),
                  if (isUploading) ...[
                    const SizedBox(height: 10),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (pickedImageBytes == null ||
                        titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please provide title and image'),
                        ),
                      );
                      return;
                    }

                    setState(() => isUploading = true);

                    final imageUrl = await uploadImageToCloudinary(
                      pickedImageBytes!,
                    );

                    setState(() => isUploading = false);

                    if (imageUrl == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Image upload failed')),
                      );
                      return;
                    }

                    final doc = await FirebaseFirestore.instance
                        .collection('categories')
                        .add({
                          'title': titleController.text.trim(),
                          'imageUrl': imageUrl,
                          'isActive': true,
                        });

                    setState(() {
                      categories.add(
                        Category(
                          id: doc.id,
                          imageUrl: imageUrl,
                          title: titleController.text.trim(),
                          isActive: true,
                        ),
                      );
                    });

                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Edit Category Dialog
  Future<void> _showEditCategoryDialog(Category category) async {
    final TextEditingController titleController = TextEditingController(
      text: category.title,
    );
    String imageUrl = category.imageUrl;
    Uint8List? pickedImageBytes;
    bool isUploading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (pickedImageBytes != null)
                    Image.memory(pickedImageBytes!, height: 100)
                  else if (imageUrl.isNotEmpty)
                    Image.network(imageUrl, height: 100)
                  else
                    const Icon(Icons.image, size: 100),
                  const SizedBox(height: 10),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('Pick New Image'),
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.image,
                        allowMultiple: false,
                      );
                      if (result != null && result.files.single.bytes != null) {
                        setState(() {
                          pickedImageBytes = result.files.single.bytes!;
                        });
                      }
                    },
                  ),
                  if (isUploading) ...[
                    const SizedBox(height: 10),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() => isUploading = true);

                    if (pickedImageBytes != null) {
                      final uploadedUrl = await uploadImageToCloudinary(
                        pickedImageBytes!,
                      );
                      if (uploadedUrl != null) {
                        imageUrl = uploadedUrl;
                      } else {
                        setState(() => isUploading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Image upload failed')),
                        );
                        return;
                      }
                    }

                    await FirebaseFirestore.instance
                        .collection('categories')
                        .doc(category.id)
                        .update({
                          'title': titleController.text.trim(),
                          'imageUrl': imageUrl,
                        });

                    setState(() {
                      categories =
                          categories.map((cat) {
                            if (cat.id == category.id) {
                              return Category(
                                id: cat.id,
                                imageUrl: imageUrl,
                                title: titleController.text.trim(),
                                isActive: cat.isActive,
                              );
                            }
                            return cat;
                          }).toList();
                    });

                    setState(() => isUploading = false);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCategoriesTable() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1000;
    final containerWidth = isLargeScreen ? screenWidth * 0.75 : 600;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: containerWidth.toDouble(),
          maxWidth: containerWidth.toDouble(),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2C),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const Text(
              //   'Categories',
              //   style: TextStyle(
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.white,
              //   ),
              //   textAlign: TextAlign.left,
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.green),
                    onPressed: _showAddCategoryDialog,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final tableWidth = constraints.maxWidth;
                  final iconWidth = tableWidth * 0.15;
                  final titleWidth = tableWidth * 0.40; // reduce title
                  final activeWidth = tableWidth * 0.20;
                  final actionWidth = tableWidth * 0.25;

                  return DataTable(
                    columnSpacing: 12,
                    columns: [
                      DataColumn(
                        label: Container(
                          alignment: Alignment.centerLeft,
                          width: iconWidth,
                          child: const Text(
                            'Icon',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Container(
                          alignment: Alignment.centerLeft,
                          width: titleWidth,
                          child: const Text(
                            'Title',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Container(
                          alignment: Alignment.centerLeft,
                          width: activeWidth,
                          child: const Text(
                            'Active',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Container(
                          alignment: Alignment.centerLeft,
                          width: actionWidth,
                          child: const Text(
                            'Actions',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ],
                    rows:
                        categories.map((cat) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Container(
                                  alignment: Alignment.centerLeft,
                                  width: iconWidth,
                                  height: 50,
                                  child:
                                      cat.imageUrl.isNotEmpty
                                          ? Image.network(
                                            cat.imageUrl,
                                            fit: BoxFit.contain,
                                          )
                                          : const Icon(
                                            Icons.image_not_supported,
                                          ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  alignment: Alignment.centerLeft,
                                  width: titleWidth,
                                  child: Text(
                                    cat.title,
                                    style: const TextStyle(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  alignment: Alignment.centerLeft,
                                  width: activeWidth,
                                  child: Switch(
                                    value: cat.isActive,
                                    onChanged:
                                        (val) =>
                                            _toggleCategoryActive(cat.id, val),
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  alignment: Alignment.centerLeft,
                                  width: actionWidth,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.amber,
                                        ),
                                        onPressed:
                                            () => _showEditCategoryDialog(cat),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed:
                                            () =>
                                                _showDeleteCategoryDialog(cat),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditServiceDialog(Service service) async {
    final nameController = TextEditingController(text: service.name);
    final priceController = TextEditingController(
      text: service.price.toString(),
    );
    bool onVisit = service.onVisit;
    String selectedCategoryId = service.categoryId;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Service'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items:
                      categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat.id,
                          child: Text(cat.title),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) selectedCategoryId = value;
                  },
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Service Name'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
                Row(
                  children: [
                    const Text('On Visit'),
                    const SizedBox(width: 10),
                    Switch(
                      value: onVisit,
                      onChanged: (val) {
                        onVisit = val;
                        // Rebuild the dialog to reflect state
                        (context as Element).markNeedsBuild();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final double parsedPrice =
                    double.tryParse(priceController.text.trim()) ?? 0.0;

                await FirebaseFirestore.instance
                    .collection('services')
                    .doc(service.id)
                    .update({
                      'name': nameController.text.trim(),
                      'price': parsedPrice,
                      'onVisit': onVisit,
                      'category': selectedCategoryId,
                    });

                setState(() {
                  services =
                      services.map((srv) {
                        if (srv.id == service.id) {
                          return Service(
                            id: srv.id,
                            categoryId: selectedCategoryId,
                            name: nameController.text.trim(),
                            price: parsedPrice,
                            onVisit: onVisit,
                            isFeatured: srv.isFeatured,
                            isActive: srv.isActive,
                          );
                        }
                        return srv;
                      }).toList();
                });

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddServiceDialog() async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    bool onVisit = false;
    String selectedCategoryId =
        categories.isNotEmpty ? categories.first.id : '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Service'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items:
                      categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat.id,
                          child: Text(cat.title),
                        );
                      }).toList(),
                  onChanged: (val) {
                    if (val != null) selectedCategoryId = val;
                  },
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
                Row(
                  children: [
                    const Text('On Visit'),
                    Switch(
                      value: onVisit,
                      onChanged: (val) {
                        onVisit = val;
                        (context as Element).markNeedsBuild();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final double parsedPrice =
                    double.tryParse(priceController.text.trim()) ?? 0.0;

                final doc = await FirebaseFirestore.instance
                    .collection('services')
                    .add({
                      'category': selectedCategoryId,
                      'name': nameController.text.trim(),
                      'price': parsedPrice,
                      'onVisit': onVisit,
                      'isFeatured': false,
                      'isActive': true,
                    });

                setState(() {
                  services.add(
                    Service(
                      id: doc.id,
                      categoryId: selectedCategoryId,
                      name: nameController.text.trim(),
                      price: parsedPrice,
                      onVisit: onVisit,
                      isFeatured: false,
                      isActive: true,
                    ),
                  );
                });

                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildServicesTable() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1000;
    final containerWidth = isLargeScreen ? screenWidth * 0.75 : 600;
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: containerWidth.toDouble(),
          maxWidth: containerWidth.toDouble(),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2C),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const Text(
              //   'Services',
              //   style: TextStyle(
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.white,
              //   ),
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Services',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.green),
                    onPressed: _showAddServiceDialog,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(
                      label: SizedBox(
                        width: containerWidth * 0.15,
                        child: const Text('Category'),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: containerWidth * 0.15,
                        child: const Text('Name'),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: containerWidth * 0.1,
                        child: const Text('Price'),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: containerWidth * 0.1,
                        child: const Text('On Visit'),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: containerWidth * 0.1,
                        child: const Text('Featured'),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: containerWidth * 0.1,
                        child: const Text('Active'),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: containerWidth * 0.1,
                        child: const Text('Actions'),
                      ),
                    ),
                  ],
                  rows:
                      services.map((srv) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                _getCategoryTitle(srv.categoryId),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            DataCell(
                              Text(
                                srv.name,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            DataCell(
                              Text(
                                '\$${srv.price.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            DataCell(
                              Text(
                                srv.onVisit ? 'Yes' : 'No',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            DataCell(
                              Switch(
                                value: srv.isFeatured,
                                onChanged:
                                    (val) =>
                                        _toggleServiceFeatured(srv.id, val),
                              ),
                            ),
                            DataCell(
                              Switch(
                                value: srv.isActive,
                                onChanged:
                                    (val) => _toggleServiceActive(srv.id, val),
                              ),
                            ),
                            DataCell(
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.amber,
                                ),
                                onPressed: () => _showEditServiceDialog(srv),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Models with copyWith for state update

class Category {
  final String id;
  final String imageUrl;
  final String title;
  final bool isActive;

  Category({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.isActive,
  });

  Category copyWith({bool? isActive}) {
    return Category(
      id: id,
      imageUrl: imageUrl,
      title: title,
      isActive: isActive ?? this.isActive,
    );
  }
}

class Service {
  final String id;
  final String categoryId;
  final String name;
  final double price;
  final bool onVisit;
  final bool isFeatured;
  final bool isActive;

  Service({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.onVisit,
    required this.isFeatured,
    required this.isActive,
  });

  Service copyWith({bool? isActive, bool? isFeatured}) {
    return Service(
      id: id,
      categoryId: categoryId,
      name: name,
      price: price,
      onVisit: onVisit,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
    );
  }
}
