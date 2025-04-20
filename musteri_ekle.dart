import 'package:flutter/material.dart';
import '../musteri_service.dart';

class MusteriEkle extends StatefulWidget {
  const MusteriEkle({super.key});

  @override
  State<MusteriEkle> createState() => _MusteriEkleState();
}

class _MusteriEkleState extends State<MusteriEkle> {
  final formKey = GlobalKey<FormState>();
  final adController = TextEditingController();
  final soyadController = TextEditingController();
  final yasController = TextEditingController();
  final calismaController = TextEditingController();
  final krediController = TextEditingController();
  bool _isLoading = false;

  void _showSnackBar(String message, {bool isError = false}) {
    final color = isError
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _kaydet() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final musteri = {
        'ad': adController.text,
        'soyad': soyadController.text,
        'yas': int.parse(yasController.text),
        'calisma_durumu': calismaController.text,
        'kredi_puani': int.parse(krediController.text),
      };

      try {
        final basarili = await musteriEkle(musteri);

        setState(() {
          _isLoading = false;
        });

        if (basarili && mounted) {
          _showSnackBar("Müşteri başarıyla eklendi!");
          Navigator.pop(context, true);
        } else {
          _showSnackBar("Müşteri eklenemedi.", isError: true);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar("Bir hata oluştu: $e", isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Müşteri Ekle"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: ListView(
                children: [
                  const Text(
                    "Yeni Müşteri Bilgileri",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: adController,
                    label: "Ad",
                    validatorText: "Ad giriniz",
                  ),
                  _buildTextField(
                    controller: soyadController,
                    label: "Soyad",
                    validatorText: "Soyad giriniz",
                  ),
                  _buildTextField(
                    controller: yasController,
                    label: "Yaş",
                    validatorText: "Yaş giriniz",
                    isNumber: true,
                  ),
                  _buildTextField(
                    controller: calismaController,
                    label: "Çalışma Durumu",
                    validatorText: "Çalışma durumu giriniz",
                  ),
                  _buildTextField(
                    controller: krediController,
                    label: "Kredi Puanı",
                    validatorText: "Kredi puanı giriniz",
                    isNumber: true,
                  ),
                  const SizedBox(height: 30),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _kaydet,
                            icon: const Icon(Icons.save),
                            label: const Text("Kaydet"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String validatorText,
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant,
        ),
        validator: (value) => value!.isEmpty ? validatorText : null,
      ),
    );
  }
}
