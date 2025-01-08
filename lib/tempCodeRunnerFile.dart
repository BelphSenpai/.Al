import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter/services.dart';

void main() => runApp(CastellsApp());

class CastellsApp extends StatefulWidget {
  @override
  _CastellsAppState createState() => _CastellsAppState();
}

class _CastellsAppState extends State<CastellsApp> {
  Color _selectedColor = const Color.fromARGB(255, 8, 252, 0); // Default color

  @override
  void initState() {
    super.initState();
    _loadSavedColor();
  }

  Future<void> _loadSavedColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? colorInt = prefs.getInt('selectedColor');
    setState(() {
      _selectedColor = colorInt != null
          ? Color(colorInt)
          : const Color.fromARGB(255, 21, 248, 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '.Al ',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: _selectedColor),
      ),
      home: HomePage(),
    );
  }

  // Add this method to update the color from outside
  void updateSelectedColor(Color newColor) {
    setState(() {
      _selectedColor = newColor;
    });
  }
}

class ResponsiveGridView extends StatelessWidget {
  final int crossAxisCount;
  final List<Widget> children;

  const ResponsiveGridView({
    Key? key,
    required this.crossAxisCount,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double availableWidth = constraints.maxWidth;
        double itemWidth = (availableWidth - (crossAxisCount - 1) * 8.0) /
            crossAxisCount; // Adjust spacing as needed

        return GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          childAspectRatio:
              (itemWidth / 100), // Adjust height based on itemWidth
          children: children,
        );
      },
    );
  }
}

class ConfigPage extends StatefulWidget {
  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  bool _darkModeEnabled = false;
  bool _notificationsEnabled = false;
  Color _selectedColor =
      const Color.fromARGB(255, 117, 243, 33); // Initial seed color

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkModeEnabled = prefs.getBool('darkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notifications') ?? false;
      int? colorInt = prefs.getInt('selectedColor');
      if (colorInt != null) {
        _selectedColor = Color(colorInt);
      }
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _darkModeEnabled);
    await prefs.setBool('notifications', _notificationsEnabled);
    await prefs.setInt('selectedColor', _selectedColor.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Configuració', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('General'),
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: _darkModeEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                  _saveSettings();
                },
              ),
              const Divider(),
              const Text('Tema'),
              const SizedBox(height: 16.0),
              ColorPicker(
                pickerColor: _selectedColor,
                onColorChanged: (Color color) {
                  setState(() {
                    _selectedColor = color;
                  });
                  _saveSettings();
                  // Notify CastellsApp about the color change
                  final context = this.context; // Capture the context
                  // Find the closest ancestor CastellsApp
                  final castellsApp =
                      context.findAncestorStateOfType<_CastellsAppState>();
                  if (castellsApp != null) {
                    castellsApp.updateSelectedColor(color);
                  }
                },
                showLabel: true,
                pickerAreaHeightPercent: 0.8,
              ),
              const Divider(),
              const Text('Notificacions'),
              SwitchListTile(
                title: const Text('Rebre notificacions'),
                value: _notificationsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  _saveSettings();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String?> selectedCastells = List.filled(6, null);
  final List<int> selectedValues = List.filled(6, 0);
  final List<String> rondaNames = [
    'Ronda 1',
    'Ronda 2',
    'Ronda 3',
    'Ronda 4',
    'Ronda 5',
    'Ronda de pilars'
  ];

  int calculateTotalPoints() {
    // Filtramos los valores para excluir la ronda de pilares
    List<int> valoresSinPilares = selectedValues
        .where((value) =>
            selectedCastells.indexOf('Pd') != selectedValues.indexOf(value))
        .toList();

    // Ordenamos los valores restantes de mayor a menor
    valoresSinPilares.sort((a, b) => b.compareTo(a));

    // Sumamos los 3 primeros valores más el valor de la ronda de pilares (siempre el último en selectedValues)
    int total =
        valoresSinPilares.take(3).reduce((a, b) => a + b) + selectedValues.last;

    return total;
  }

  void updateCastell(int ronda, String castell, int value) {
    setState(() {
      selectedCastells[ronda] = castell;
      selectedValues[ronda] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // Implement menu logic here
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('.Al',
                style: TextStyle(color: Colors.white, fontFamily: 'Oswald')),
            const SizedBox(width: 8.0),
            Image.asset(
              'assets/icon/icon.png', // Replace with the actual path to your image
              height: 24.0,
              width: 24.0,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConfigPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) {
                return CastellListTile(
                  index: index,
                  rondaName: rondaNames[index],
                  selectedCastells: selectedCastells,
                  selectedValues: selectedValues,
                  updateCastell: updateCastell,
                );
              },
            ),
          ),
          Card(
            margin: EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Total: ${calculateTotalPoints()} punts',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CastellListTile extends StatelessWidget {
  final int index;
  final String rondaName;
  final List<String?> selectedCastells;
  final List<int> selectedValues;
  final Function(int, String, int) updateCastell;

  const CastellListTile({
    required this.index,
    required this.rondaName,
    required this.selectedCastells,
    required this.selectedValues,
    required this.updateCastell,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: FutureBuilder<Uint8List?>(
        future: selectedCastells[index] != null
            ? _loadImageFromAsset(
                'assets/images/${selectedCastells[index]}.png')
            : null, // Return null if no castell is selected
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return Image.memory(
                snapshot.data!,
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              );
            } else {
              // Use a Placeholder widget
              return const Placeholder(
                fallbackHeight: 50,
                fallbackWidth: 50,
                color: Colors.grey,
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
              ),
            );
          }
        },
      ),
      title: Text(rondaName),
      subtitle: Text(selectedCastells[index] != null
          ? '${selectedCastells[index]} (${selectedValues[index]} punts)'
          : 'Selecciona un castell'),
      trailing: Icon(Icons.arrow_forward),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CastellSelectorPage(
              ronda: index,
              selectedCastells: selectedCastells,
              selectedValues: selectedValues,
              updateCastell: updateCastell,
              onCancel: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        );

        if (result != null) {
          updateCastell(index, result['name'], result['points']);
        }
      },
    );
  }

  Future<Uint8List?> _loadImageFromAsset(String path) async {
    try {
      final ByteData data = await rootBundle.load(path);
      return data.buffer.asUint8List();
    } catch (e) {
      // Return null if the image asset is not found
      return null;
    }
  }
}

class CastellSelectorPage extends StatefulWidget {
  final int ronda;
  final List<String?> selectedCastells;
  final List<int> selectedValues;
  final Function(int, String, int) updateCastell;
  final VoidCallback onCancel;

  CastellSelectorPage({
    required this.ronda,
    required this.selectedCastells,
    required this.selectedValues,
    required this.updateCastell,
    required this.onCancel,
  });

  @override
  _CastellSelectorPageState createState() => _CastellSelectorPageState();
}

class _CastellSelectorPageState extends State<CastellSelectorPage> {
  final List<Map<String, dynamic>> castells = [
    {'name': '2d6', 'carregat': 175, 'descarregat': 200},
    {'name': 'Pd5', 'carregat': 185, 'descarregat': 210},
    {'name': '9d6', 'carregat': 230, 'descarregat': 265},
    {'name': '4d7', 'carregat': 240, 'descarregat': 275},
    {'name': '3d7', 'carregat': 250, 'descarregat': 290},
    {'name': '3d7a', 'carregat': 330, 'descarregat': 360},
    {'name': '4d7a', 'carregat': 345, 'descarregat': 380},
    {'name': '7d7', 'carregat': 350, 'descarregat': 400},
    {'name': '5d7', 'carregat': 365, 'descarregat': 420},
    {'name': '5d7a', 'carregat': 415, 'descarregat': 460},
    {'name': '3d7ps', 'carregat': 425, 'descarregat': 475},
    {'name': '9d7', 'carregat': 500, 'descarregat': 575},
    {'name': '2d7', 'carregat': 525, 'descarregat': 605},
    {'name': '4d8', 'carregat': 550, 'descarregat': 635},
    {'name': 'Pd6', 'carregat': 580, 'descarregat': 665},
    {'name': '3d8', 'carregat': 610, 'descarregat': 700},
    {'name': '7d8', 'carregat': 760, 'descarregat': 875},
    {'name': '2d8f', 'carregat': 800, 'descarregat': 920},
    {'name': 'Pd7f', 'carregat': 835, 'descarregat': 960},
    {'name': '5d8', 'carregat': 880, 'descarregat': 1010},
    {'name': '4d8a', 'carregat': 965, 'descarregat': 1060},
    {'name': '3d8a', 'carregat': 1005, 'descarregat': 1110},
    {'name': '5d8a', 'carregat': 1055, 'descarregat': 1165},
    {'name': '4d9f', 'carregat': 1270, 'descarregat': 1460},
    {'name': '3d9f', 'carregat': 1335, 'descarregat': 1530},
    {'name': '9d8', 'carregat': 1665, 'descarregat': 1915},
    {'name': '3d8ps', 'carregat': 1825, 'descarregat': 2005},
    {'name': '2d9fm', 'carregat': 1835, 'descarregat': 2110},
    {'name': 'Pd8fm', 'carregat': 1925, 'descarregat': 2210},
    {'name': '7d9f', 'carregat': 2020, 'descarregat': 2320},
    {'name': '5d9f', 'carregat': 2090, 'descarregat': 2400},
    {'name': '4d9fa', 'carregat': 2250, 'descarregat': 2475},
    {'name': '3d9fa', 'carregat': 2315, 'descarregat': 2555},
    {'name': '4d9sf', 'carregat': 2680, 'descarregat': 3195},
    {'name': '2d8sf', 'carregat': 2765, 'descarregat': 3225},
    {'name': '3d10fm', 'carregat': 2775, 'descarregat': 3405},
    {'name': '4d10fm', 'carregat': 2870, 'descarregat': 3510},
    {'name': '9d9f', 'carregat': 3190, 'descarregat': 3670},
    {'name': 'Pd9fmp', 'carregat': 3410, 'descarregat': 4060},
    {'name': '3d9sf', 'carregat': 3570, 'descarregat': 4250},
    {'name': '2d10fmp', 'carregat': 3880, 'descarregat': 4460},
    {'name': '4d10fsm', 'carregat': 3935, 'descarregat': 4685},
    {'name': '3d10fsm', 'carregat': 4125, 'descarregat': 4910},
  ];

  String sortOption = 'points'; // Options: 'name', 'points'
  String searchText = '';
  bool isAscending = true;

  List<Map<String, dynamic>> filterCastells() {
    List<Map<String, dynamic>> filteredCastells = List.from(castells);

    if (searchText.isNotEmpty) {
      filteredCastells = filteredCastells
          .where((castell) =>
              castell['name'].toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    }

    // Remove descarregat castells if they are selected in any other ronda
    filteredCastells.removeWhere((castell) {
      return widget.selectedCastells.any((selectedCastell) =>
          selectedCastell == castell['name'] &&
          widget.selectedCastells.indexOf(selectedCastell) != widget.ronda &&
          widget.selectedValues[
                  widget.selectedCastells.indexOf(selectedCastell)] ==
              castell['descarregat']);
    });

    if (widget.ronda == 5) {
      // Si es la ronda de pilares
      filteredCastells
          .retainWhere((castell) => castell['name'].startsWith('Pd'));
    }

    switch (sortOption) {
      case 'name':
        filteredCastells.sort((a, b) => isAscending
            ? a['name'].compareTo(b['name'])
            : b['name'].compareTo(a['name']));
        break;
      case 'points':
        filteredCastells.sort((a, b) => isAscending
            ? a['carregat'].compareTo(b['carregat'])
            : b['carregat'].compareTo(a['carregat']));
        break;
    }

    return filteredCastells;
  }

  void showCastellOptions(
      BuildContext context, Map<String, dynamic> castell) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Selecciona el tipus',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'Intent',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              onTap: () => Navigator.pop(
                  context, {'name': castell['name'], 'points': 0}),
            ),
            ListTile(
              title: Text(
                'Carregat (${castell['carregat']} punts)',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              onTap: () => Navigator.pop(context,
                  {'name': castell['name'], 'points': castell['carregat']}),
            ),
            ListTile(
              title: Text(
                'Descarregat (${castell['descarregat']} punts)',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              onTap: () {
                Navigator.pop(context, {
                  'name': castell['name'],
                  'points': castell['descarregat']
                });
              },
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> castellsToShow = filterCastells();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // Implement menu logic here
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 8.0),
            const Text('.Al', style: TextStyle(color: Colors.white)),
            Image.asset(
              'assets/icon/icon.png', // Replace with the actual path to your image
              height: 24.0,
              width: 24.0,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConfigPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    widget.onCancel();
                  },
                ),
                SizedBox(width: 10),
                Expanded(
                  child: const Text(
                    'Selecciona el castell',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ),
                // ... other widgets
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20), // Add padding to the Row
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: IconButton(
                    icon: Icon(isAscending
                        ? Icons.arrow_upward
                        : Icons.arrow_downward),
                    onPressed: () {
                      setState(() {
                        isAscending = !isAscending;
                      });
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: DropdownButton<String>(
                    value: sortOption,
                    onChanged: (String? newValue) {
                      setState(() {
                        sortOption = newValue!;
                      });
                    },
                    items: <String>['name', 'points']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value == 'name' ? 'Nom' : 'Punts'),
                      );
                    }).toList(),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 150, // Adjust width as needed
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchText = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar castell...',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        isDense: true,
                      ),
                      style: TextStyle(fontSize: 12.0),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
              height: 16.0), // Add spacing between AppBar and buttons
          const SizedBox(height: 8.0), // Add spacing between text and buttons
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 0.73,
              children: List.generate(castellsToShow.length, (index) {
                final castell = castellsToShow[index];
                return GestureDetector(
                  onTap: () => showCastellOptions(context, castell),
                  child: Card(
                    elevation: 0, // Remove card elevation
                    margin: EdgeInsets.zero, // Remove card margin
                    child: Padding(
                      padding: const EdgeInsets.all(9), // Add internal padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer, // Set your desired background color
                              borderRadius: BorderRadius.circular(
                                  20), // Adjust corner radius
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  10), // Add some padding inside the box
                              child: Column(
                                // Maintain the column layout
                                children: [
                                  FutureBuilder<Uint8List?>(
                                    future: _loadImageFromAsset(
                                        'assets/images/${castell['name']}.png'),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        if (snapshot.hasData) {
                                          return Image.memory(
                                            snapshot.data!,
                                            width: 150,
                                            height: 150,
                                            fit: BoxFit.contain,
                                          );
                                        } else {
                                          // Use a Placeholder widget
                                          return const Placeholder(
                                            fallbackHeight: 150,
                                            fallbackWidth: 150,
                                            color: Colors.grey,
                                          );
                                        }
                                      } else {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(castell['name'],
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${castell['carregat']} pts | ${castell['descarregat']} pts',
                            style: TextStyle(fontSize: 10.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

Future<Uint8List?> _loadImageFromAsset(String path) async {
  try {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  } catch (e) {
    // Return null if the image asset is not found
    return null;
  }
}
