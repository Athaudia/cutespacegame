$ships = []
$ships << {img: "ship001.png", armor: 100, name: "Amy",   slots: [{type: :small_wep, off: [0,5]}, {type: :util}]}
$ships << {img: "ship002.png", armor: 100, name: "Allie", slots: [{type: :small_wep, off: [-6,0]},{type: :small_wep, off: [6,0]}]}
$bullets = []
$bullets << {timer: 40, fade: 10, speed: 5.0,  dmg: 10,  img: "bullet001.png"}
$bullets << {timer: 10, fade: 30, speed: 5.0,  dmg: 2,   img: "bullet001.png"}
$bullets << {timer: 40, fade: 10, speed: 10.0, dmg: 200, img: "bullet002.png"}
$bullets << {timer: 15, fade: 1,  speed: 10.0,  dmg: 0,   img: "bullet003.png", onhit: :nothing, onexplode:
	[{bullet: $bullets[0], multi: 128, spread_mode: :angle, multi_spread: 360/128.0}]}

$weapons = []
$weapons << {bullet: $bullets[0], cooldown: 10,  icon: "icon001.png", name: "Pink Pellet",        price: 100}
$weapons << {bullet: $bullets[0], cooldown: 30,  icon: "icon001.png", name: "P.P. Baby",          price: 10}
$weapons << {bullet: $bullets[0], cooldown: 5,   icon: "icon002.png", name: "P.P. Turbo",         price: 500}
$weapons << {bullet: $bullets[0], cooldown: 10,  icon: "icon003.png", name: "P.P. Duo",           price: 500,   multi: 2}
$weapons << {bullet: $bullets[0], cooldown: 10,  icon: "icon007.png", name: "P.P. Duo Spread",    price: 500,   multi: 2, spread_mode: :angle, multi_spread: 10}
$weapons << {bullet: $bullets[0], cooldown: 10,  icon: "icon004.png", name: "P.P. Triple",        price: 1000,  multi: 3}
$weapons << {bullet: $bullets[0], cooldown: 10,  icon: "icon008.png", name: "P.P. Triple Spread", price: 1000,  multi: 3, spread_mode: :angle, multi_spread: 10}
$weapons << {bullet: $bullets[0], cooldown: 10,  icon: "icon005.png", name: "P.P. Quad",          price: 2000,  multi: 4}
$weapons << {bullet: $bullets[0], cooldown: 10,  icon: "icon009.png", name: "P.P. Quad Spread",   price: 2000,  multi: 4, spread_mode: :angle, multi_spread: 10}
$weapons << {bullet: $bullets[1], cooldown: 2,   icon: "icon010.png", name: "P.P. Star",          price: 4000,  multi: 8, spread_mode: :angle, multi_spread: 360/8, :rot_speed => 3}
$weapons << {bullet: $bullets[1], cooldown: 2,   icon: "icon010.png", name: "P.P. Star CCW",      price: 4000,  multi: 8, spread_mode: :angle, multi_spread: 360/8, :rot_speed => -3}
$weapons << {bullet: $bullets[2], cooldown: 60,  icon: "icon012.png", name: "Pink Bolt",          price: 10000, recoil: 2}
$weapons << {bullet: $bullets[2], cooldown: 90,  icon: "icon013.png", name: "P.B. Extreme",       price: 15000, multi: 2, multi_spread: 8, recoil: 3}
$weapons << {bullet: $bullets[3], cooldown: 600, icon: "icon011.png", name: "Red Bomb",           price: 20000, recoil: 2}
$weapons << {bullet: $bullets[3], cooldown: 400, icon: "icon011.png", name: "R.B. Turbo",         price: 40000, recoil: 2}

$utils = []
$utils << {cooldown: 100,  icon: "icon201.png", name: "Repairer",        price: 100,   passive: true, repair: 5}

$waves = [
[[0,0]],
[[0,0]],
[[0,0],[0,0]],
[[0,0],[0,0]],
[[1,0,0]],
[[1,0,0],[1,0,0]],
[[1,2,2]],
[[1,2,2],[1,2,2]],
[[0,6,0],[0,6,0]],
[[0,6,0],[0,6,0],[0,6,0],[0,6,0]],
[[0,8,0],[0,8,0]],
[[0,8,0],[0,8,0],[0,8,0],[0,8,0]],
[[0,8,0],[0,8,0],[0,8,0],[0,8,0],[0,8,0],[0,8,0],[0,8,0],[0,8,0]],
[[0,8,0],[0,8,0],[0,8,0],[0,8,0],[0,8,0],[0,8,0],[0,8,0],[0,8,0],[0,8,0],[0,8,0],[0,8,0],[0,8,0],[0,8,0],[0,8,0],[0,8,0],[0,8,0]],
[[1,8,8],[1,8,8],[1,8,8],[1,8,8],[1,8,8],[1,8,8],[1,8,8],[1,8,8],[1,8,8],[1,8,8],[1,8,8],[1,8,8],[1,8,8],[1,8,8],[1,8,8],[1,8,8],[1,9,10],[1,9,10]],
]
