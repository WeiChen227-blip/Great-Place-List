import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:section_13/models/place.dart';
import 'package:section_13/widgets/image_input.dart';
import 'package:section_13/widgets/location_input.dart';
import '../providers/places.dart';

class InputForm extends ConsumerWidget {
  const InputForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    File? selectedImage;
    String? title;
    PlaceLocation? selectedLocation;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Place')),
      body: Padding(
        padding: const EdgeInsets.all(
          16.0,
        ), // Add padding for better positioning
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                maxLength: 50,
                style: const TextStyle(
                  color: Colors.white,
                ), // <-- Add this line

                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (newValue) => title = newValue,
              ),

              const SizedBox(height: 24), // Space between field and button
              ImageInput(
                onSelectImage: (image) {
                  selectedImage = image;
                },
              ),
              const SizedBox(height: 16),
              LocationInput(
                onSelectLocation: (location) {
                  selectedLocation = location;
                },
              ),
              const SizedBox(height: 24), // Space between field and button
              SizedBox(
                width: 200, // Make button full width
                height: 48, // Set button height
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      // Handle form submission
                      final newPlace = Place(
                        title: title!,
                        image: selectedImage!,
                        location: selectedLocation!,
                      );
                      ref
                          .read(placesProvider.notifier)
                          .addPlace(
                            newPlace,
                            selectedImage!,
                            selectedLocation!,
                          );
                      Navigator.of(context).pop();
                    } else {
                      // Show error if image is not selected
                      if (selectedImage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select an image'),
                          ),
                        );
                      }

                      if (title == null || title!.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a title')),
                        );
                      }
                    }
                  },
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center content
                    children: const [
                      Icon(Icons.add),
                      SizedBox(width: 8),
                      Text('Add Place'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
