import 'package:flutter/material.dart';



typedef StringCallback = Function(String value);
typedef ListCallback = Function(List<String> value);


// -------------------- Vẽ hình tròn trang trí -------------------- 

Container circle(Color color, double radius) {
  return Container(
    width: radius * 2,
    height: radius * 2,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.all(Radius.circular(radius))
    )
  );
}



// -------------------- Thông báo đăng ký / đăng nhập không hợp lệ -------------------- 

void warningModal(BuildContext context, String warningText) {
  showModalBottomSheet<void>( context: context, builder: (BuildContext context) {
    return Container(
      height: 240,
      color: Colors.amber.shade300,
      child: Center( child: Container(
        padding: const EdgeInsets.only(left: 60, right: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, 
          children: [
            Text(warningText, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 30),
            BigButton( bold: true, width: 240, label: "Quay lại", onPressed: () => Navigator.pop(context) )
          ],
        ),
      )),
    );
  });
}



// -------------------- Trường nhập (Nhập các thông tin nhỏ) -------------------- 

class RegularTextField extends StatefulWidget {
  RegularTextField({ Key? key,
    required this.controller, required this.labelText,
    this.obscureText = false, this.text = ""
  }) : super(key: key) {
    controller.text = text;
  }
  final TextEditingController controller;
  final String labelText;
  final String text;
  final bool obscureText;
  
  @override
  State<RegularTextField> createState() => _RegularTextFieldState();
}

class _RegularTextFieldState extends State<RegularTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10, left: 30, right: 30),
      child: TextField(
        
        style: TextStyle( fontSize: 20, color: Colors.amber.shade900 ),
        cursorColor: Colors.amber.shade900,

        obscureText: widget.obscureText,

        controller: widget.controller,
        decoration: InputDecoration(
    
          labelText: widget.labelText,
          labelStyle: TextStyle( fontSize: 18, color: Colors.grey.shade700 ),
          floatingLabelStyle: TextStyle( color: Colors.brown.shade700 ),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.yellow.shade100)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.yellow.shade200)),
    
        ),
      ),
    );
  }
}



// -------------------- Trường nhập (Nhập địa chỉ) -------------------- 


class AddressTextField extends StatefulWidget {
  const AddressTextField({
    Key? key,
    required this.controller,
    required this.onSubmitted,
    // required this.onChanged
  }) : super(key: key);
  final TextEditingController controller;
  final StringCallback onSubmitted;
  // final ListCallback onChanged;

  @override
  State<AddressTextField> createState() => _AddressTextFieldState();
}


class _AddressTextFieldState extends State<AddressTextField> {

  @override
  Widget build(BuildContext context) {
    return Container(

      padding: const EdgeInsets.only(left: 5, right: 5),
      height: 55,
      
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(9)),
        border: Border.all(
          color: Colors.amber.shade300,
          width: 3
        )
      ),

      child: TextField(
        controller: widget.controller,
        // onChanged: (String addr) async {
        //   List<String> newHintAddrs = await map_reader.getHintLocations(addr);
        //   widget.onChanged(newHintAddrs);
        // },
        onSubmitted: (String addr) => widget.onSubmitted(addr),
        
        decoration: InputDecoration(

          hintText: "Bạn muốn đi đâu？",

          border: InputBorder.none,

          prefixIcon: IconButton(
            icon: const Icon(Icons.search, size: 20),
            color: Colors.blueGrey.shade600,
            onPressed: () => widget.onSubmitted(widget.controller.text),
          ),

          suffixIcon: IconButton(
            icon: const Icon(Icons.clear, size: 20),
            color: Colors.blueGrey.shade600,
            onPressed: () => setState(() => widget.controller.clear() )
          )

        ),
      ),
    );
  }
}



// -------------------- Nút "bự" -------------------- 

class BigButton extends StatefulWidget {
  const BigButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.width = 230.0,
    this.fontSize = 24,
    this.bold = false,
    this.color = Colors.transparent,
    this.pressable = true
  }) : super(key: key);
  
  final String label;
  final VoidCallback onPressed;
  final double width;
  final double fontSize;
  final bool bold;
  final Color color;
  final bool pressable;

  @override
  State<BigButton> createState() => _BigButtonState();
}


class _BigButtonState extends State<BigButton> {

  @override
  Widget build(BuildContext context) {
    
    if (widget.bold) {
      return SizedBox(
        width: widget.width,
        child: ElevatedButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(15),
            backgroundColor: (widget.color.opacity == Colors.transparent.opacity)
                              ? (widget.pressable ?  Colors.deepOrange.shade600 : Colors.brown.shade600) : widget.color,
            foregroundColor: Colors.white
          ),
          onPressed: () => widget.pressable ? widget.onPressed() : null,
          child: Text(widget.label, style: TextStyle(fontSize: widget.fontSize))
        ),
      );
    }
    else {
      return SizedBox(
        width: widget.width,
        child: OutlinedButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(15),
            side: BorderSide(color: Colors.yellow.shade100)
          ),
          onPressed: () => widget.pressable ? widget.onPressed() : null,
          child: Text(widget.label, style: TextStyle(fontSize: widget.fontSize, color: (widget.pressable ?  Colors.deepOrange.shade600 : Colors.brown.shade600)))
        ),
      );
    }
  }
}



// -------------------- Icon / Emoji hình xe -------------------- 

String getVehicleName(int vehicleID) {
  switch (vehicleID) {
    case 0: return "Để sau";
    case 1: return "Xe máy";
    case 2: return "Xe ô tô";
    default: return "[ERROR]";
  }
}

class CarWidget extends StatelessWidget {
  const CarWidget({ Key? key, this.text = "", required this.type }) : super(key: key);
  final String text;
  final int type;

  String getCarEmoji() {
    switch (type) {
      case 0: return "⏳";
      case 1: return "🛵";
      case 2: return "🚗";
      default: return "❌";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child:
        (text.isEmpty) ? Center(child: SizedBox.fromSize(
          size: const Size.fromRadius(36),
          child: Text(getCarEmoji(), style: const TextStyle(fontSize: 56))
        ))
        :
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox.fromSize(
              size: const Size.fromRadius(36),
              child: Text(getCarEmoji(), style: const TextStyle(fontSize: 56))
            ),
            const SizedBox(height: 5),
            Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            )
          ]
        )
      );
  }
}



class PositionBox extends StatelessWidget {
  const PositionBox({ Key? key, required this.icon, required this.position }) : super(key: key);
  final Icon icon;
  final String position;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15),
      height: 55,
      decoration: BoxDecoration(
        color: Colors.yellow.shade50,
        borderRadius: const BorderRadius.all(Radius.circular(9)),
        border: Border.all(
          color: Colors.amber.shade300,
          width: 3
        )
      ),
      child: Row(children: [
        icon,
        const SizedBox(width: 15),
        SizedBox(
          width: 250,
          height: 55,
          child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Align(
            alignment: Alignment.centerLeft,
            child: Text(position, style: const TextStyle(fontSize: 16))
          ))
        )
      ])
    );
  }
}


class PriceButton extends StatelessWidget {
  const PriceButton({ super.key, required this.text });
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        color: Colors.yellow.shade50,
        borderRadius: const BorderRadius.all(Radius.circular(9)),
        border: Border.all(
          color: Colors.amber.shade300,
          width: 3
        )
      ),
      child: Center(child: Text(text, style: const TextStyle(fontSize: 18)))
    );
  }
}



class HorizontalLine extends StatelessWidget {
  const HorizontalLine({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5, bottom: 5, right: 15),
      height: 1,
      color: Colors.amber.shade300
    );
  }
}



class CustomerPoint extends StatelessWidget {
  const CustomerPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20, height: 20,
      decoration: BoxDecoration(
        color: Colors.amber.shade800,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        border: Border.all(color: Colors.white, width: 3)
      )
    );
  }

}



class DestiPoint extends StatelessWidget {
  const DestiPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20, height: 20,
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade900,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        border: Border.all(color: Colors.white, width: 3)
      )
    );
  }
}



class DriverPoint extends StatelessWidget {
  const DriverPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20, height: 20,
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade300,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        border: Border.all(color: Colors.brown.shade700, width: 3)
      )
    );
  }
}


