// ============================================================================
// BRAS ROBOTIQUE v2 — 2 servos + parallelogramme + pince a engrenages
// ============================================================================
// Repere assemblage :  Origine = pivot A (axe MG996R)
//                      X = avant (direction du bras)
//                      Y = lateral (axe du servo MG996R)
//                      Z = haut
// ============================================================================
// Pince adaptee de tallerinventores/educational-robot-arm-with-6DOF (GPLv3)
// 2 machoires a engrenage involute, le SG90 entraine la machoire droite,
// l'engrenage transmet en sens inverse a la machoire gauche.
// ============================================================================
// Requires:  MCAD  (installe par defaut avec OpenSCAD)
//   Si erreur "Can't open MCAD/involute_gears.scad" :
//   → Menu File > Show Library Folder, verifier que MCAD/ existe.
//   → Sinon : https://github.com/openscad/MCAD
// ============================================================================

use <MCAD/involute_gears.scad>

$fn = 60;

// ─── PARAMETRES CRITIQUES DU PARALLELOGRAMME ─────────────────────────────
L_bras      = 100;   // mm — longueur bras ET biellette (identiques !)
H_pivot     = 30;    // mm — entraxe A-B ET C-D (identiques !)

// ─── TOLERANCE ───────────────────────────────────────────────────────────
tol = 0.3;

// ─── VISSERIE ────────────────────────────────────────────────────────────
m3 = 3.2;
m2 = 2.2;

// ─── BIELLETTE ───────────────────────────────────────────────────────────
bielle_y = 14;   // offset Y de la biellette

// ─── PINCE — engrenages (adapte tallerinventores) ────────────────────────
// Diametral pitch 0.39 → pitch_d = 10/0.39 ≈ 25.6 mm
// center_dist ≈ 25.6 → on arrondit a 26 mm, jaw_offset = 13
_jaw_n     = 10;      // dents par machoire
_jaw_dp    = 0.39;    // diametral pitch (MCAD convention : N/D en mm)
_jaw_gt    = 6;       // epaisseur engrenage (mm)
_jaw_off   = 13;      // demi-distance entre pivots machoires
_jaw_phase = 18;      // offset angulaire pour engrener (360/(2*N))
_jaw_pa    = 20;      // angle de pression
_jaw_bl    = 0.5;     // jeu entre dents (backlash)
_jaw_hub   = 20;      // diametre moyeu
_jaw_bore  = 4;       // alesage central


// =====================================================================
//  MG996R  — fantome, axe +Z, origine = centre axe sortie
// =====================================================================
module mg996r() {
    bw = 40.7; bd = 19.7; bh = 36.5;
    ear_h = 2.5; ear_ov = 7.0;
    hub_d = 12; hub_h = 4; axe_d = 5.8; axe_h = 3;
    sfb = 32.9;

    color([0.18,0.18,0.22]) {
        translate([-bw/2,-bd/2,-sfb]) cube([bw,bd,bh]);
        cylinder(d=hub_d, h=hub_h);
        cylinder(d=axe_d, h=hub_h+axe_h);
        translate([-(bw/2+ear_ov),-bd/2, bh-sfb-ear_h-6.4])
            cube([bw+2*ear_ov, bd, ear_h]);
    }
}


// =====================================================================
//  SG90  — fantome, axe +Z, origine = centre axe sortie
// =====================================================================
module sg90() {
    bw = 22.5; bd = 12.0; bh = 22.5;
    ear_t = 2; ear_w = 32.5;
    hub_d = 5.5; hub_h = 4;
    axe_d = 4.7; axe_h = 3;
    sfb = bh + hub_h - 1;

    color([0.12,0.12,0.55]) {
        translate([-bw/2,-bd/2,-sfb]) cube([bw,bd,bh]);
        translate([0,0,-sfb+bh-0.5])
            hull() {
                cylinder(d=hub_d, h=hub_h+0.5);
                translate([5.5,0,0]) cylinder(d=11.6, h=hub_h+0.5);
            }
        cylinder(d=axe_d, h=axe_h);
        translate([-ear_w/2,-bd/2, -sfb+15.5])
            cube([ear_w, bd, ear_t]);
    }
}


// =====================================================================
//  PIECE 1 — Support epaule (U-bracket + fourche pivot B)
// =====================================================================
module support_epaule() {
    w  = 3; bt = 4; r = 3;
    px = 41+2*tol; py = 35; pz = 20+2*tol;
    z_bot  = -(pz/2+w+bt);
    z_side = pz/2+w;
    z_top  = H_pivot+6;
    base_x = px+2*w+8;
    base_y = py+2*w+4;
    _biel_gap = 0.5;  // jeu lateral fourche (par cote)

    difference() {
        union() {
            // Base arrondie
            hull()
                for (dx=[-(base_x/2-r), base_x/2-r])
                    for (dy=[-(py+w+2-r), (w+2-r)])
                        translate([dx,dy,z_bot]) cylinder(r=r,h=bt);
            // Parois U
            translate([-(px/2+w),-(py+w),z_bot+bt])
                cube([w, py+2*w, z_side-z_bot-bt]);
            translate([px/2,-(py+w),z_bot+bt])
                cube([w, py+2*w, z_side-z_bot-bt]);
            translate([-(px/2+w),-(py+w),z_bot+bt])
                cube([px+2*w, w, z_side-z_bot-bt]);
            // Plaque avant fuselee
            hull() {
                translate([-(px/2+w),-w,z_bot+bt]) cube([px+2*w,w,0.1]);
                translate([-14,-w,z_top-0.1]) cube([28,w,0.1]);
            }
            // Goussets
            for (sx=[-(px/2+w), px/2])
                hull() {
                    translate([sx,-w,z_side-0.1]) cube([w,w,0.1]);
                    translate([sx>0?14-w:-14,-w,z_top-0.1]) cube([w,w,0.1]);
                }
            // Fourche pivot B (jeu _biel_gap par cote pour la biellette de 12mm)
            hull() {
                translate([-7,0,H_pivot-6]) cube([14,2,12]);
                translate([-7,bielle_y-6-_biel_gap-3,H_pivot-5]) cube([14,2,10]);
            }
            // Flasques arrondis (cylindres au lieu de cubes)
            for (fy=[bielle_y-6-_biel_gap-1.5, bielle_y+6+_biel_gap+1.5])
                hull() {
                    translate([0,fy,H_pivot-4])
                        rotate([-90,0,0]) cylinder(d=8,h=3,center=true);
                    translate([0,fy,H_pivot+4])
                        rotate([-90,0,0]) cylinder(d=8,h=3,center=true);
                    translate([0,fy,H_pivot])
                        rotate([-90,0,0]) cylinder(d=12,h=3,center=true);
                }
        }
        // --- Logement MG996R ---
        // Le servo est monte avec rotate([-90,0,0]) → axe en +Y.
        // Corps : X ±20.35, Y ≈ -33..+4, Z ±9.85
        // Oreilles : depassent de 7mm en ±X, minces en Y (2.5mm)
        //
        //  Vue du dessus (plan XY) :
        //
        //     Paroi G   Corps servo   Paroi D
        //     ┃  ┃  ┌──────────────┐  ┃  ┃
        //     ┃  ┃  │   40.7mm     │  ┃  ┃  ← poche corps
        //     ┃  ┗━━┿━━oreille━━━━┿━━┛  ┃  ← encoche 55mm
        //     ┃     │              │     ┃
        //     ┃     └──────────────┘     ┃
        //

        // Poche corps servo (41mm, entre les parois)
        translate([-px/2, -py, -pz/2])
            cube([px, py+w+1, pz]);

        // Fente oreilles : 55mm de large, traverse les parois,
        // mince en Y (3.5mm), ouverte vers le HAUT pour insertion.
        // Le servo glisse par le haut : le corps entre dans la poche,
        // les oreilles passent dans la fente.
        translate([-55/2-tol, -4.1 - 1.75, -pz/2])
            cube([55+2*tol, 3.5, z_side + pz/2 + 1]);

        // Trou passage axe + moyeu (plaque avant)
        translate([0, -w-0.1, 0])
            rotate([-90, 0, 0]) cylinder(d=13, h=w+4);

        // Vis oreilles (2xM3 dans chaque paroi, traversent en X)
        // Positionnees AU CENTRE des parois (pas au bord)
        _wall_center_x = px/2 + w/2;   // ~22.3mm
        for (sx=[-1, 1])
            translate([sx*_wall_center_x, -4.1, 0])
                rotate([0, 90, 0])
                    cylinder(d=m3, h=w+2, center=true);

        // --- Pivot B (M3 traversant + fraisage + ecrou) ---
        translate([0,bielle_y-10,H_pivot])
            rotate([-90,0,0]) cylinder(d=m3,h=20);
        translate([0,bielle_y-6-_biel_gap-3,H_pivot])
            rotate([-90,0,0]) cylinder(d=6.5,h=2.5);
        translate([0,bielle_y+6+_biel_gap+0.5,H_pivot])
            rotate([-90,30,0]) cylinder(d=6.6,h=2.6,$fn=6);
        // Fixation chassis (4xM3, vis par le dessous)
        // Fraisage tete de vis COTE INTERIEUR (entre base et servo)
        // → la tete de vis ne depasse pas dans la poche servo
        for (dx=[-18,18]) for (dy=[-13,13])
            translate([dx,-(py/2+w)+dy,z_bot-0.1]) {
                cylinder(d=m3, h=bt+0.2);                    // trou traversant
                translate([0, 0, bt-2]) cylinder(d=6.5, h=2.2);  // fraisage tete M3 (interieur)
            }
        // Passage cable
        translate([-4,-py-w-0.1,-pz/2]) cube([8,w+0.2,4]);
    }
}


// =====================================================================
//  ALESAGE CANNELE MG996R — anti-glissement
// =====================================================================
// L'arbre MG996R a 25 cannelures (d=5.8mm).
// Ce module genere le NEGATIF de l'arbre : a soustraire du bras
// pour creer un emboitement qui transmet le couple sans glisser.
module _mg996r_spline(h) {
    n = 25;              // nombre de cannelures
    d_ext = 5.9;         // diametre pointe des dents (+ jeu impression)
    d_fond = 5.0;        // diametre fond des dents
    tooth_w = 0.7;       // largeur d'une dent a la pointe (mm)

    linear_extrude(h)
    union() {
        circle(d=d_fond, $fn=50);
        for (i=[0:n-1])
            rotate(i * 360/n)
                polygon([
                    [d_fond/2 - 0.1, -tooth_w/2],
                    [d_ext/2,        -tooth_w/3],
                    [d_ext/2,         tooth_w/3],
                    [d_fond/2 - 0.1,  tooth_w/2]
                ]);
    }
}


// =====================================================================
//  PALONNIER MG996R — visualisation assemblage
// =====================================================================
// Le palonnier (horn) fourni avec le MG996R.
// C'est LUI qui transmet le couple : son alesage cannele
// s'emboite sur l'arbre, et il est boulonne au bras.
module palonnier_mg996r() {
    ep = 2.5;          // epaisseur
    hub_d = 8;         // diametre moyeu
    arm_l = 14;        // longueur d'un bras depuis le centre
    arm_w = 5;         // largeur bras

    color([0.92, 0.92, 0.92])
    difference() {
        union() {
            cylinder(d=hub_d, h=ep);
            // Croix 4 bras
            for (a=[0, 90, 180, 270])
                rotate([0, 0, a])
                    hull() {
                        cylinder(d=arm_w, h=ep);
                        translate([arm_l, 0, 0]) cylinder(d=arm_w-1, h=ep);
                    }
        }
        // Alesage cannele (simplifie pour visu)
        translate([0, 0, -0.1]) cylinder(d=5.8, h=ep+0.2, $fn=25);
        // Vis centrale M3
        translate([0, 0, -0.1]) cylinder(d=m3, h=ep+0.2);
        // Trous aux bouts des bras (M2)
        for (a=[0, 90, 180, 270])
            rotate([0, 0, a])
                translate([arm_l-2, 0, -0.1]) cylinder(d=m2, h=ep+0.2);
    }
}


// =====================================================================
//  PIECE 2 — Bras principal (tube A→C)
// =====================================================================
// IMPORTANT : le renfort epaule est UNIQUEMENT du cote +Y (exterieur).
// Le cote -Y est la face qui vient CONTRE le palonnier/arbre.
//
// Vue en coupe Y (epaule) :
//
//   Support    Palonnier   Bras (renfort)
//   bracket     croix      ┌──────────┐
//   ┃          ╋          │          │
//   ┃    arbre──●──cannelures────────│  ← axe rotation
//   ┃          ╋          │          │
//   ┃                     └──────────┘
//   ← -Y                          +Y →
//
//   Le bras ne depasse PAS en -Y au-dela de l'axe.
//   Le palonnier est ENTRE le support et le bras.

// Cotes cle :
_shaft_y    = 2;       // Y ou l'arbre sort du support (~2mm)
_pal_ep     = 2.8;     // epaisseur palonnier + jeu
_bras_y_min = _shaft_y + _pal_ep;  // ~4.8mm : face interne du bras
_bras_y_max = _bras_y_min + 12;    // ~16.8mm : face externe

module bras() {
    L  = L_bras;
    sx = 15;          // largeur section tube (X)
    sz = 12;          // hauteur section tube (Z)
    w  = 2.5;         // epaisseur parois tube
    rl = 15;          // longueur renfort

    pal_arm_l = 14;
    pal_arm_w = 5.5;

    y0 = _bras_y_min;   // face interne (~4.8)
    y1 = _bras_y_max;   // face externe (~16.8)
    ym = (y0+y1)/2;      // centre du bras en Y
    bras_ey = y1 - y0;   // epaisseur bras en Y (~12)

    // Raccourcir le tube pour ne PAS percuter la platine CD.
    // A 45 deg, le bord haut du tube (Z=sz/2) se projette en +X
    // de sz/2 * sin(45) ≈ 4.2mm. Le tube doit s'arreter AVANT la platine.
    _tube_end = L - 10;   // tube s'arrete 10mm avant le pivot theorique

    difference() {
        union() {
            // Tube creux (raccourci)
            difference() {
                translate([0, ym-sx/2, -sz/2]) cube([_tube_end, sx, sz]);
                translate([rl, ym-sx/2+w, -(sz/2-w)])
                    cube([_tube_end-rl+0.1, sx-2*w, sz-2*w]);
            }
            // Renfort epaule (cote +Y de l'axe uniquement)
            hull() {
                translate([-5, y0, -12]) cube([5, bras_ey, 24]);
                translate([rl, ym-sx/2, -sz/2]) cube([0.1, sx, sz]);
            }
            // Embout C — patte de pivot FINE vers la platine CD
            // Hauteur reduite (±3mm en Z) pour ne pas depasser en X apres rotation
            hull() {
                translate([_tube_end-1, ym-3, -3]) cube([1, 6, 6]);
                translate([L-7, -1, -3]) cube([1, 4, 6]);
            }
            // Nervure
            translate([rl, ym-1, -sz/2-2]) cube([_tube_end-rl-3, 2, 2]);
        }

        // --- Fixation epaule ---
        translate([0, y0-0.1, 0])
            rotate([-90, 0, 0])
                _mg996r_spline(bras_ey + 0.2);
        translate([0, y0-0.1, 0])
            rotate([-90, 0, 0])
                linear_extrude(_pal_ep + 0.1)
                    union() {
                        circle(d=9);
                        for (a=[0,90,180,270])
                            rotate(a)
                                hull() {
                                    circle(d=pal_arm_w);
                                    translate([pal_arm_l,0])
                                        circle(d=pal_arm_w-1);
                                }
                    }
        for (a=[0, 90, 180, 270])
            translate([(pal_arm_l-2)*cos(a), y0-0.1, (pal_arm_l-2)*sin(a)])
                rotate([-90, 0, 0])
                    cylinder(d=m2, h=bras_ey+0.2);
        translate([0, y0-0.1, 0])
            rotate([-90, 0, 0])
                cylinder(d=m3, h=bras_ey+0.2);

        // --- Pivot C (trou M3 en Y pour la liaison avec la platine) ---
        translate([L-7.5, -3, 0])
            rotate([-90, 0, 0])
                cylinder(d=m3, h=10);
    }
}


// =====================================================================
//  PIECE 2b — Platine CD
// =====================================================================
module platine_cd() {
    pt = 5; pw = 20;
    _bg = 0.5;   // jeu lateral fourche (par cote)

    difference() {
        union() {
            // Corps principal (barre verticale C→D)
            hull() {
                translate([-pt/2,-pw/2,-2]) cube([pt,pw,4]);
                translate([-pt/2,-pw/2,H_pivot-2]) cube([pt,pw,4]);
            }
            // Patte vers fourche D
            hull() {
                translate([-pt/2,pw/2-2,H_pivot-4]) cube([pt,2,8]);
                translate([-pt/2,bielle_y-7,H_pivot-4]) cube([pt,2,8]);
            }
            // Fourche pivot D (jeu _bg par cote)
            translate([-pt/2,bielle_y-6-_bg-3,H_pivot-5]) cube([pt,3,10]);
            translate([-pt/2,bielle_y+6+_bg,H_pivot-5])   cube([pt,3,10]);
            for (fy=[bielle_y-6-_bg-1.5, bielle_y+6+_bg+1.5])
                translate([0,fy,H_pivot])
                    rotate([-90,0,0]) cylinder(d=10,h=3,center=true);
            // Bossage pivot C
            rotate([0,90,0]) cylinder(d=12,h=pt,center=true);
            // Plateforme pince (face avant +X, montage horizontal)
            translate([pt/2, -12, -10])
                cube([3, 24, 14]);
        }

        // --- Pivot C (liaison bras, M3 traversant en Y) ---
        translate([0, -pw/2-1, 0])
            rotate([-90, 0, 0])
                cylinder(d=m3, h=pw+2);

        // --- Pivot D (M3 traversant en Y + fraisage + ecrou) ---
        translate([0,bielle_y-10,H_pivot])
            rotate([-90,0,0]) cylinder(d=m3,h=20);
        // Fraisage tete vis
        translate([0,bielle_y-6-_bg-3,H_pivot])
            rotate([-90,0,0]) cylinder(d=6.5,h=2.5);
        // Logement ecrou nylstop
        translate([0,bielle_y+6+_bg+0.5,H_pivot])
            rotate([-90,30,0]) cylinder(d=6.6,h=2.6,$fn=6);

        // --- Fixation pince (2xM3 traversant en X) ---
        for (dy=[-8, 8])
            translate([0, dy, -3])
                rotate([0, 90, 0])
                    cylinder(d=m3, h=pt+8, center=true);
        // Fraisage tete vis pince (face -X)
        for (dy=[-8, 8])
            translate([-pt/2-0.1, dy, -3])
                rotate([0, -90, 0])
                    cylinder(d=6.5, h=2.5);
    }
}


// =====================================================================
//  PIECE 7 — Biellette parallelogramme
// =====================================================================
module biellette() {
    L = L_bras; bw = 12; bh = 8; boss = 14;
    difference() {
        // Hull des 2 bossages = barre lisse sans aretes carrees
        hull()
            for (px=[0, L])
                translate([px, 0, 0])
                    rotate([-90, 0, 0])
                        cylinder(d=boss, h=bw, center=true);
        // Trous pivots M3
        for (px=[0, L])
            translate([px, 0, 0])
                rotate([-90, 0, 0])
                    cylinder(d=m3, h=bw+2, center=true);
    }
}


// (Pieces TPU supprimees — pas utiles a ce stade)


// =====================================================================
//  PINCE — Machoire (engrenage + doigt)
// =====================================================================
// Repere local machoire :
//   Origine = centre de l'engrenage (= pivot, axe Z)
//   Engrenage de Z=0 a Z=_jaw_gt
//   Doigt s'etend vers +Y (pointe a Y≈50) dans le plan Z=0.._jaw_gt
//   Griffe dentelee sur la face interne (-X pour la droite)
//
// Apres placement dans la pince : rotate([-90,0,0]) met le doigt
// vers -Z (bas) et le pivot le long de +Y.

// Base commune (avant decoupe droite/gauche)
module _machoire_base(phase) {
    difference() {
        union() {
            // Engrenage involute (MCAD)
            translate([0, 0, _jaw_gt])
            rotate([180, 0, phase])
                gear(
                    number_of_teeth  = _jaw_n,
                    diametral_pitch  = _jaw_dp,
                    pressure_angle   = _jaw_pa,
                    clearance        = 0.2,
                    gear_thickness   = _jaw_gt,
                    rim_thickness    = _jaw_gt,
                    rim_width        = 6,
                    hub_thickness    = _jaw_gt,
                    hub_diameter     = _jaw_hub,
                    bore_diameter    = _jaw_bore,
                    circles          = 0,
                    backlash         = _jaw_bl
                );

            // Doigt : pivot → genou (15,15) → bout (0,50)
            hull() {
                cylinder(r=10, h=_jaw_gt);
                translate([15, 15, 0]) cylinder(r=10, h=_jaw_gt);
            }
            hull() {
                translate([15, 15, 0]) cylinder(r=10, h=_jaw_gt);
                translate([0, 50, 0])  cylinder(r=10, h=_jaw_gt);
            }
        }

        // Surface de grip plate (face interne, angle 15 deg)
        translate([-4.5, 35, -1])
            rotate([0, 0, -15])
                scale([-1, 1, 1])
                    cube([20, 40, _jaw_gt+2]);

        // Rainures de grip (dentelures)
        for (i = [-3:1.9:30])
            translate([-4.75 + i*sin(15), 35 + i*cos(15), -1])
                rotate([0, 0, 30])
                    cube([2, 2, _jaw_gt+2]);
    }
}

// Machoire droite (entrainee par le palonnier SG90)
module machoire_droite() {
    difference() {
        _machoire_base(0);
        // Alesage central (passage axe SG90)
        translate([0, 0, -1]) cylinder(r=2.6, h=_jaw_gt+2);
        // Empreinte du palonnier SG90 (horn cutout)
        // Seulement 1.6 mm de profondeur depuis la face superieure
        // pour ne PAS manger les dents de l'engrenage
        translate([0, 0, _jaw_gt - 1.6])
            rotate([0, 0, -45])
                hull() {
                    cylinder(r=3.8, h=2);
                    translate([0, 14.6, 0]) cylinder(r=2.1, h=2);
                }
    }
}

// Machoire gauche (entrainee par engrenage, sens inverse)
// Tourne LIBREMENT sur une vis M3 traversante.
// Vis M3x25 + 2 rondelles + ecrou nylstop
module machoire_gauche() {
    mirror([1, 0, 0])
    difference() {
        _machoire_base(_jaw_phase);
        // Alesage pivot : trou M3 avec jeu pour tourner librement
        // Diametre 3.4mm (jeu 0.2mm sur la vis M3)
        translate([0, 0, -1]) cylinder(d=3.4, h=_jaw_gt+2);
        // Evidement pour rondelle (face -Z, ne depasse pas)
        translate([0, 0, -0.1]) cylinder(d=7, h=1);
        // Evidement pour rondelle (face +Z)
        translate([0, 0, _jaw_gt-1+0.1]) cylinder(d=7, h=1);
    }
}


// =====================================================================
//  PINCE — Corps / bracket
// =====================================================================
// Bracket en U qui porte les 2 pivots machoire + le SG90.
// Fixation par le dessus sur la platine CD.
//
// Repere local bracket :
//   Z=0 : surface de fixation (haut)
//   Z= -wall_h : bas du bracket
//   Pivots machoires a Z = _pivot_z, X = ±_jaw_off
//
// Le bracket est oriente pour que les doigts pendent vers -Z
// et que les machoires s'ouvrent en ±X.

_brk_wall   = 4;      // epaisseur parois
_brk_depth  = 14;     // profondeur bracket en Y (assez pour _jaw_gt + jeu)
_brk_height = 28;     // hauteur totale du bracket
_pivot_z    = -22;     // Z des pivots machoires (dans le bracket)

module pince_corps() {
    hw = _jaw_off + _brk_wall;      // demi-largeur
    d  = _brk_depth;
    h  = _brk_height;
    pz = _pivot_z;

    difference() {
        union() {
            // Plaque de fixation (haut, Z=0)
            translate([-hw-5, -d/2, -3])
                cube([2*hw+10+10, d, 3]);

            // Paroi gauche
            translate([-hw-_brk_wall, -d/2, pz-3])
                cube([_brk_wall, d, -pz+3+3]);

            // Paroi droite (plus epaisse pour le servo)
            translate([hw, -d/2, pz-3])
                cube([_brk_wall+10, d, -pz+3+3]);

            // Paroi arriere
            translate([-hw-_brk_wall, d/2-_brk_wall, pz-3])
                cube([2*hw+2*_brk_wall+10, _brk_wall, -pz+3+3]);

            // Renforts pivots (bossages)
            for (x=[-_jaw_off, _jaw_off])
                translate([x, 0, pz])
                    rotate([90, 0, 0])
                        cylinder(d=14, h=d, center=true);
        }

        // Trous pivots machoires (traversants en Y)
        // Vis M3x25 traverse : paroi → rondelle → machoire → rondelle → paroi → ecrou
        for (x=[-_jaw_off, _jaw_off])
            translate([x, -d/2-0.1, pz])
                rotate([-90, 0, 0])
                    cylinder(d=m3, h=d+0.2);

        // Fraisage tete de vis M3 (face -Y, entree de la vis)
        for (x=[-_jaw_off, _jaw_off])
            translate([x, -d/2-0.1, pz])
                rotate([-90, 0, 0])
                    cylinder(d=6.5, h=2.5);   // tete hex/cylindrique M3

        // Empreinte ecrou nylstop M3 (face +Y, cote arriere)
        // Hex : cle de 5.5mm → d_inscrit=5.5 → d_circonscrit=6.35
        for (x=[-_jaw_off, _jaw_off])
            translate([x, d/2-2.5, pz])
                rotate([-90, 30, 0])
                    cylinder(d=6.6, h=2.6, $fn=6);  // hex M3 nylstop

        // Degagement pour les engrenages (entre les 2 pivots)
        // Les dents doivent pouvoir tourner librement
        translate([-_jaw_off+5, -d/2-0.1, pz-15])
            cube([2*_jaw_off-10, d+0.2, 30]);

        // Passage SG90 (cote droit)
        // Le SG90 est a Y=0, arbre vers +Y (machoire), corps vers -Y (haut en monde)
        // Le corps part vers -Y → passe par le cote ouvert du bracket (pas de paroi)
        // → en monde, apres rotations assemblage, le corps monte vers +Z (ne gene pas)
        //
        // Passage moyeu SG90 (d=12) dans la zone du pivot droit
        // Le moyeu est entre la machoire et le corps
        translate([_jaw_off, -d/2-0.1, pz])
            rotate([-90, 0, 0])
                cylinder(d=14, h=d+0.2);

        // Trous fixation platine (2xM3, entraxe 16mm)
        for (dx=[-8, 8])
            translate([dx, 0, -3.1])
                cylinder(d=m3, h=3.2);

        // Ouverture basse (les doigts doivent passer)
        translate([-_jaw_off+2, -d/2-0.1, pz-3-0.1])
            cube([2*_jaw_off-4, d+0.2, 3+0.2]);
    }
}


// =====================================================================
//  PINCE — Assemblage complet
// =====================================================================
// angle : ouverture de la pince en degres
//   0 = position par defaut (gap ~6mm entre surfaces de grip)
//   15 = ouvert (~40mm)
//   20 = grand ouvert (~50mm)
//
// Le SG90 est coaxial avec la machoire droite (meme axe de rotation).
// Le palonnier SG90 s'emboite dans l'empreinte de la machoire droite.
// L'engrenage de la machoire droite entraine la machoire gauche
// en sens INVERSE → les 2 doigts s'ouvrent/ferment symetriquement.

module pince_asm(angle=0) {
    pz = _pivot_z;
    col_body  = [0.80, 0.35, 0.35];
    col_jaw_r = [0.85, 0.75, 0.40];
    col_jaw_l = [0.75, 0.65, 0.35];
    col_sg    = [0.12, 0.12, 0.55];

    // Corps/bracket
    color(col_body) pince_corps();

    // Machoire droite (entrainee par SG90)
    // Placement : pivot a (jaw_off, 0, pz), axe pivot = Y
    // rotate([-90,0,0]) : doigt (local +Y) → monde -Z (vers le bas)
    //                    : axe engrenage (local Z) → monde +Y (pivot)
    color(col_jaw_r)
    translate([_jaw_off, -_jaw_gt/2, pz])
    rotate([-90, 0, 0])
    rotate([0, 0, -angle])
        machoire_droite();

    // Machoire gauche (entrainee par engrenage)
    color(col_jaw_l)
    translate([-_jaw_off, -_jaw_gt/2, pz])
    rotate([-90, 0, 0])
    rotate([0, 0, angle])          // sens inverse !
        machoire_gauche();

    // SG90 fantome
    // rotate([-90,0,0]) : arbre (local +Z) → monde +Y (vers la machoire)
    //                    : corps (local -Z) → monde -Y
    // En monde : -Y du pince → +Z (vers le HAUT) apres rotations assemblage
    // → le corps du SG90 monte, il ne gene PAS la prise d'objets en bas
    color(col_sg, 0.6)
    translate([_jaw_off, 0, pz])
    rotate([-90, 0, 0])
    rotate([0, 0, -angle])
        sg90();
}


// =====================================================================
//  ASSEMBLAGE COMPLET
// =====================================================================
module assemblage_complet(angle_epaule=45, angle_pince=10) {

    col_s = [0.55, 0.70, 0.85];
    col_b = [0.35, 0.78, 0.38];

    a  = angle_epaule;
    Cx = L_bras * cos(a);
    Cz = L_bras * sin(a);

    // === SUPPORT EPAULE ===
    color(col_s) support_epaule();


    // === MG996R (axe en +Y) ===
    rotate([-90,0,0]) mg996r();

    // === PALONNIER MG996R (entre le support et le bras) ===
    // Le palonnier est sur l'arbre, cote +Y.
    // Il transmet le couple : cannelures arbre → palonnier → bras
    rotate([0, -a, 0])
        translate([0, _shaft_y, 0])
            rotate([-90, 0, 0])
                palonnier_mg996r();

    // === BRAS (uniquement cote +Y de l'arbre) ===
    color(col_s) rotate([0,-a,0]) bras();

    // === PLATINE CD au point C ===
    translate([Cx,0,Cz]) color(col_s) platine_cd();

    // === BIELLETTE B→D ===
    color(col_b)
        translate([0,bielle_y,H_pivot])
        rotate([0,-a,0])
            biellette();

    // === PINCE ===
    // Montee sur la face avant de la platine CD, a l'horizontale.
    // rotate([0,0,90])  : ouverture des machoires en ±Y (lateral)
    // rotate([0,-90,0]) : bascule la pince a l'horizontale
    //   → les doigts pointent vers +X (avant) au lieu de -Z (bas)
    //   → la pince reste horizontale grace au parallelogramme
    translate([Cx + 7, 0, Cz - 3])
    rotate([0, -90, 0])
    rotate([0, 0, 90])
        pince_asm(angle_pince);

}


// =====================================================================
//  RENDU
// =====================================================================
assemblage_complet(angle_epaule = 45, angle_pince = 10);

// --- Animation : View > Animate (FPS=10, Steps=100)
// a_ep = 10 + 70 * (0.5 + 0.5*sin($t*360));
// a_pi = 20 * (0.5 + 0.5*sin($t*360*2));
// assemblage_complet(angle_epaule=a_ep, angle_pince=a_pi);

// =====================================================================
//  EXPORT STL (decommenter UN SEUL)
// =====================================================================
// support_epaule();
// bras();
// platine_cd();
// biellette();
// pince_corps();
// machoire_droite();
// machoire_gauche();
