// ============================================================================
// BRAS ROBOTIQUE v3 — Rewrite propre + detection de collisions
// ============================================================================
// Repere :  Origine = pivot A (axe MG996R)
//           X = avant, Y = lateral (+Y = cote bras), Z = haut
// ============================================================================
// Requires: MCAD (inclus avec OpenSCAD)
// ============================================================================

use <MCAD/involute_gears.scad>
$fn = 50;

// ========================== SECTION 1 : PARAMETRES ==========================

// --- Parallelogramme (CRITIQUE : bras = biellette, AB = CD) ---
L_bras       = 100;
H_pivot      = 30;

// --- Tolerances ---
tol          = 0.3;     // jeu general par face
tol_pivot    = 0.2;     // jeu supplementaire pivots (rotation libre)

// --- Visserie ---
m3           = 3.0 + tol;          // percage M3 = 3.3
m3_head_d    = 6.5;
m3_head_h    = 2.5;
m3_nut_d     = 6.6;                // hex M3 nylstop (cle 5.5 → circum 6.35)
m3_nut_h     = 2.6;
m2           = 2.0 + tol;

// --- MG996R ---
mg_bw = 40.7;  mg_bd = 19.7;  mg_bh = 36.5;
mg_sfb = 32.9;                     // axe depuis le bas du corps
mg_ear_ov = 7.0;                   // depassement oreille par cote
mg_ear_total = mg_bw + 2*mg_ear_ov;  // 54.7
mg_ear_t = 2.5;                    // epaisseur oreille
mg_hub_d = 12;  mg_hub_h = 4;
mg_axe_d = 5.8; mg_axe_h = 3;

// --- SG90 ---
sg_bw = 22.5;  sg_bd = 12.0;  sg_bh = 22.5;
sg_ear_w = 32.5;  sg_ear_t = 2.0;
sg_hub_d = 5.5;  sg_hub_h = 4;
sg_axe_d = 4.7; sg_axe_h = 3;

// --- Palonnier MG996R ---
pal_ep = 2.5;  pal_arm_l = 14;  pal_arm_w = 5;

// --- Biellette ---
biel_w = 12;  biel_d = 14;       // largeur Y, diametre bossage

// --- Layout Y (chaine de cotes le long de +Y depuis l'axe) ---
//     support_wall | gap | palonnier | gap | bras_inner ... bras_outer
support_wall_t = 3;
y_pal_start    = support_wall_t + tol;                 // ~3.3
y_pal_end      = y_pal_start + pal_ep;                 // ~5.8
y_bras_inner   = y_pal_end + tol;                      // ~6.1
y_bras_outer   = y_bras_inner + 12;                    // ~18.1
y_bras_center  = (y_bras_inner + y_bras_outer) / 2;   // ~12.1
y_biel_center  = 14;              // offset Y biellette (spec)

// --- Fork (meme geometrie aux pivots B et D) ---
fork_gap       = biel_w + 2*tol;  // 12.6 — la biellette passe dedans
fork_inner_y   = y_biel_center - fork_gap/2;     // ~7.7
fork_outer_y   = y_biel_center + fork_gap/2;     // ~20.3
fork_t         = 3;               // epaisseur d'un flasque

// --- Bras ---
bras_sx = 12;  bras_sz = 10;  bras_w = 2.5;  // section tube (reduit pour eviter biellette)
bras_tube_end  = L_bras - 12;    // le tube s'arrete 12mm avant C (anti-collision)
// Verification : tube Y = ym ± sx/2 = 12.1 ± 6 = [6.1, 18.1]
// Biellette Y = biel_center ± biel_w/2 = 14 ± 6 = [8, 20]
// Chevauchement Y : [8, 18.1] — mais biellette est a Z=H_pivot(30), tube a Z≈0
// → pas de collision tant que le tube ne monte pas a Z=30 (OK)

// --- Platine CD ---
plt_t = 5;  plt_w = 20;          // epaisseur X, largeur Y

// --- Pince (engrenages MCAD, adapte tallerinventores) ---
jaw_n = 10;  jaw_dp = 0.39;  jaw_gt = 6;  jaw_off = 13;
jaw_phase = 18;  jaw_pa = 20;  jaw_bl = 0.5;
jaw_hub_d = 20;  jaw_bore_d = 4;
brk_wall = 4;  brk_depth = 14;  brk_height = 28;  pivot_z_brk = -22;

// --- Pince : offset X depuis la platine ---
pince_x_offset = plt_t/2 + 6.5;  // 9mm devant la platine → degage plateforme + paroi arriere


// ====================== SECTION 2 : MODULES FANTOMES =======================

module mg996r() {
    color([0.18,0.18,0.22]) {
        translate([-mg_bw/2,-mg_bd/2,-mg_sfb]) cube([mg_bw,mg_bd,mg_bh]);
        cylinder(d=mg_hub_d, h=mg_hub_h);
        cylinder(d=mg_axe_d, h=mg_hub_h+mg_axe_h);
        translate([-(mg_bw/2+mg_ear_ov),-mg_bd/2, mg_bh-mg_sfb-mg_ear_t-6.4])
            cube([mg_ear_total, mg_bd, mg_ear_t]);
    }
}

module sg90() {
    sfb = sg_bh + sg_hub_h - 1;
    color([0.12,0.12,0.55]) {
        translate([-sg_bw/2,-sg_bd/2,-sfb]) cube([sg_bw,sg_bd,sg_bh]);
        translate([0,0,-sfb+sg_bh-0.5])
            hull() {
                cylinder(d=sg_hub_d, h=sg_hub_h+0.5);
                translate([5.5,0,0]) cylinder(d=11.6, h=sg_hub_h+0.5);
            }
        cylinder(d=sg_axe_d, h=sg_axe_h);
        translate([-sg_ear_w/2,-sg_bd/2,-sfb+15.5]) cube([sg_ear_w,sg_bd,sg_ear_t]);
    }
}

module palonnier_mg996r() {
    color([0.92,0.92,0.92])
    difference() {
        union() {
            cylinder(d=8, h=pal_ep);
            for (a=[0,90,180,270])
                rotate([0,0,a])
                    hull() {
                        cylinder(d=pal_arm_w, h=pal_ep);
                        translate([pal_arm_l,0,0]) cylinder(d=pal_arm_w-1, h=pal_ep);
                    }
        }
        translate([0,0,-0.1]) cylinder(d=mg_axe_d, h=pal_ep+0.2, $fn=25);
        translate([0,0,-0.1]) cylinder(d=m3, h=pal_ep+0.2);
        for (a=[0,90,180,270])
            rotate([0,0,a])
                translate([pal_arm_l-2,0,-0.1]) cylinder(d=m2, h=pal_ep+0.2);
    }
}

// Alesage cannele MG996R (negatif, a soustraire)
module _mg996r_spline(h) {
    n = 25;  d_ext = 5.9;  d_fond = 5.0;  tw = 0.7;
    linear_extrude(h)
    union() {
        circle(d=d_fond, $fn=50);
        for (i=[0:n-1]) rotate(i*360/n)
            polygon([[d_fond/2-0.1,-tw/2],[d_ext/2,-tw/3],[d_ext/2,tw/3],[d_fond/2-0.1,tw/2]]);
    }
}


// =================== SECTION 3 : PIECES IMPRIMABLES ========================

// ----- PIECE 1 : Support epaule -----
module support_epaule() {
    w = support_wall_t;  bt = 4;  r = 3;
    px = mg_bw + 2*tol;           // poche corps = 41.3
    py = 35;                       // profondeur poche en Y
    pz = mg_bd + 2*tol;           // hauteur poche en Z = 20.3
    z_bot = -(pz/2 + w + bt);     // bas de la base
    z_side = pz/2 + w;            // haut des parois
    z_top = H_pivot + 6;          // haut de la plaque avant
    base_x = px + 2*w + 8;
    base_y = py + 2*w + 4;

    // Position Y des oreilles apres rotate([-90,0,0]) du servo
    // Oreilles: Z_orig = mg_bh - mg_sfb - mg_ear_t - 6.4 = -5.3
    //           Apres R_x(-90) : Z → Y, donc oreilles a Y ≈ -5.3..-2.8
    ear_y_center = -(mg_sfb - mg_bh + 6.4 + mg_ear_t/2);  // ≈ -4.15
    ear_slot_w   = mg_ear_t + 2*tol;                        // 3.1mm en Y

    difference() {
        union() {
            // Base arrondie
            hull()
                for (dx=[-(base_x/2-r), base_x/2-r])
                    for (dy=[-(py+w+2-r), (w+2-r)])
                        translate([dx,dy,z_bot]) cylinder(r=r,h=bt);
            // Parois U (gauche, droite, arriere)
            for (sx=[-(px/2+w), px/2])
                translate([sx,-(py+w),z_bot+bt]) cube([w, py+2*w, z_side-z_bot-bt]);
            translate([-(px/2+w),-(py+w),z_bot+bt]) cube([px+2*w, w, z_side-z_bot-bt]);
            // Plaque avant (fuselee vers le haut)
            hull() {
                translate([-(px/2+w),-w,z_bot+bt]) cube([px+2*w,w,0.1]);
                translate([-14,-w,z_top-0.1]) cube([28,w,0.1]);
            }
            // Goussets lateraux
            for (sx=[-(px/2+w), px/2])
                hull() {
                    translate([sx,-w,z_side-0.1]) cube([w,w,0.1]);
                    translate([sx>0?14-w:-14,-w,z_top-0.1]) cube([w,w,0.1]);
                }
            // Fourche pivot B
            hull() {
                translate([-7,0,H_pivot-6]) cube([14,2,12]);
                translate([-7,fork_inner_y-fork_t,H_pivot-5]) cube([14,2,10]);
            }
            for (fy=[fork_inner_y-fork_t, fork_outer_y])
                translate([-7,fy,H_pivot-5]) cube([14,fork_t,10]);
            for (fy=[fork_inner_y-fork_t/2, fork_outer_y+fork_t/2])
                translate([0,fy,H_pivot])
                    rotate([-90,0,0]) cylinder(d=10,h=fork_t,center=true);
        }

        // --- Poche corps servo ---
        translate([-px/2,-py,-pz/2]) cube([px, py+w+1, pz]);

        // --- Fente oreilles (55mm de large, 3.1mm en Y, ouverte vers le haut) ---
        translate([-mg_ear_total/2-tol, ear_y_center-ear_slot_w/2, -pz/2])
            cube([mg_ear_total+2*tol, ear_slot_w, z_side+pz/2+1]);

        // --- Passage axe + moyeu ---
        translate([0,-w-0.1,0]) rotate([-90,0,0]) cylinder(d=mg_hub_d+2, h=w+4);

        // --- Vis oreilles (2xM3 au centre des parois, traversent en X) ---
        for (sx=[-1,1])
            translate([sx*(px/2+w/2), ear_y_center, 0])
                rotate([0,90,0]) cylinder(d=m3, h=w+2, center=true);

        // --- Pivot B (M3 en Y, fraisage + ecrou) ---
        translate([0, fork_inner_y-fork_t-1, H_pivot])
            rotate([-90,0,0]) cylinder(d=m3, h=fork_gap+2*fork_t+2);
        translate([0, fork_inner_y-fork_t-0.1, H_pivot])
            rotate([-90,0,0]) cylinder(d=m3_head_d, h=m3_head_h);
        translate([0, fork_outer_y+fork_t-m3_nut_h, H_pivot])
            rotate([-90,30,0]) cylinder(d=m3_nut_d, h=m3_nut_h+0.1, $fn=6);

        // --- Fixation chassis (4xM3, fraisage interieur) ---
        for (dx=[-18,18]) for (dy=[-13,13])
            translate([dx,-(py/2+w)+dy,z_bot-0.1]) {
                cylinder(d=m3, h=bt+0.2);
                translate([0,0,bt-m3_head_h]) cylinder(d=m3_head_d, h=m3_head_h+0.2);
            }

        // --- Passage cable ---
        translate([-4,-py-w-0.1,-pz/2]) cube([8,w+0.2,4]);
    }
}


// ----- PIECE 2 : Bras principal -----
// REGLES anti-collision :
//   - Le renfort epaule reste dans la poche servo (Z = ±pz/2 max)
//   - Le tube est PLUS HAUT en Y que la biellette (pas de chevauchement)
//   - La patte pivot C longe la platine par le cote +Y (ne la traverse pas)
//   - La patte va jusqu'a X=L pour atteindre le pivot
module bras() {
    L = L_bras;
    sx = bras_sx;  sz = bras_sz;  w = bras_w;
    rl = 15;
    te = bras_tube_end;  // tube s'arrete a L-12

    y0 = y_bras_inner;   // 6.1
    y1 = y_bras_outer;   // 18.1
    ym = y_bras_center;  // 12.1

    // Fourche pivot C — 2 flasques entourant la platine CD
    // Les flasques sont a Y=±10.8, DEHORS de la platine (Y=±10),
    // donc pas de collision en Z quelle que soit la rotation du bras.
    // On utilise la pleine hauteur du tube pour un maximum de rigidite.
    _fc_t   = 3;                                // epaisseur flasque Y
    _fc_hz  = sz/2;                             // 5mm — pleine hauteur tube
    _fc_gap = plt_w + 2*tol + 1;                // 21.6mm jeu pour la platine
    _fc_in  = -(_fc_gap/2 + _fc_t);             // -13.8 face ext flasque interieur
    _fc_out = _fc_gap/2;                        // 10.8 face int flasque exterieur
    _fc_xs  = L - plt_t - 2;                    // 93 — fin du sweep (avant la platine)

    difference() {
        union() {
            // Tube creux (Y decale, s'arrete a te=88)
            difference() {
                translate([0, ym-sx/2, -sz/2]) cube([te, sx, sz]);
                translate([rl, ym-sx/2+w, -(sz/2-w)])
                    cube([te-rl+0.1, sx-2*w, sz-2*w]);
            }
            // Renfort epaule — hauteur limitee pour ne PAS entrer dans le boitier MG996R
            // Le servo apres rotation occupe Z = ±mg_bd/2 = ±9.85
            // Le renfort doit rester DEHORS → Z = ±(mg_bd/2 + tol) = ±10.15 minimum
            // → on limite le renfort a la section du tube (sz = ±5)
            hull() {
                translate([-5, y0, -sz/2]) cube([5, y1-y0, sz]);
                translate([rl, ym-sx/2, -sz/2]) cube([0.1, sx, sz]);
            }
            // Fourche pivot C — 2 flasques entourant la platine
            // Vis M3 traverse : flasque int → platine → flasque ext → nylstop
            // Section flasque = 3mm(Y) × 10mm(Z) — meme hauteur que le tube

            // Flasque exterieur (+Y) — transition depuis le tube
            hull() {
                translate([te-1, _fc_out, -_fc_hz])
                    cube([1, y1 - _fc_out, 2*_fc_hz]);
                translate([L-1, _fc_out, -_fc_hz])
                    cube([1, _fc_t, 2*_fc_hz]);
            }
            // Flasque interieur (-Y) — sweep puis longe la platine
            // Le sweep Y va de y0=6.1 a _fc_in=-13.8 et se termine
            // a _fc_xs=93, AVANT la platine (a X=L-plt_t/2=97.5)
            hull() {
                translate([te-1, ym-sx/2, -_fc_hz])
                    cube([1, sx, 2*_fc_hz]);
                translate([_fc_xs, _fc_in, -_fc_hz])
                    cube([1, _fc_t, 2*_fc_hz]);
            }
            // Prolongement du flasque int le long de la platine
            translate([_fc_xs, _fc_in, -_fc_hz])
                cube([L - _fc_xs, _fc_t, 2*_fc_hz]);
            // Bossages pivot C (renfort autour du trou M3)
            for (fy=[_fc_in + _fc_t/2, _fc_out + _fc_t/2])
                translate([L, fy, 0])
                    rotate([-90,0,0]) cylinder(d=sz, h=_fc_t, center=true);
        }

        // Alesage cannele (face -Y)
        translate([0, y0-0.1, 0]) rotate([-90,0,0]) _mg996r_spline(y1-y0+0.2);
        // Empreinte palonnier
        translate([0, y0-0.1, 0]) rotate([-90,0,0])
            linear_extrude(pal_ep+tol+0.1)
                union() {
                    circle(d=9);
                    for (a=[0,90,180,270]) rotate(a)
                        hull() {
                            circle(d=pal_arm_w+tol);
                            translate([pal_arm_l,0]) circle(d=pal_arm_w-1+tol);
                        }
                }
        // Vis M3 centrale
        translate([0, y0-0.1, 0]) rotate([-90,0,0]) cylinder(d=m3, h=y1-y0+0.2);
        // 4x M2 palonnier
        for (a=[0,90,180,270])
            translate([(pal_arm_l-2)*cos(a), y0-0.1, (pal_arm_l-2)*sin(a)])
                rotate([-90,0,0]) cylinder(d=m2, h=y1-y0+0.2);
        // Pivot C (M3 en Y, traverse les 2 flasques + la platine)
        translate([L, _fc_in-0.1, 0])
            rotate([-90,0,0]) cylinder(d=m3, h=_fc_gap + 2*_fc_t + 0.2);
        // Fraisage tete M3 (cote -Y)
        translate([L, _fc_in-0.1, 0])
            rotate([-90,0,0]) cylinder(d=m3_head_d, h=m3_head_h);
        // Ecrou nylstop (cote +Y)
        translate([L, _fc_out+_fc_t-m3_nut_h, 0])
            rotate([-90,30,0]) cylinder(d=m3_nut_d, h=m3_nut_h+0.1, $fn=6);
    }
}


// ----- PIECE 2b : Platine CD -----
module platine_cd() {
    pt = plt_t;  pw = plt_w;
    difference() {
        union() {
            // Barre verticale C→D — efilee vers D pour eviter la biellette
            // Biellette Y_min = y_biel_center - biel_w/2 = 8
            // On recule de 1mm supplementaire pour marge large
            // Bas (C) : largeur pw=20, Haut (D) : largeur 2*(fork_inner_y-1)=13.4
            _plt_w_top = 2*(fork_inner_y - 1);  // 13.4mm — Y_max = 6.7, marge 1.3mm
            hull() {
                translate([-pt/2,-pw/2,-2]) cube([pt,pw,4]);
                translate([-pt/2,-_plt_w_top/2,H_pivot-2]) cube([pt,_plt_w_top,4]);
            }
            // Patte vers fourche D — reste sous la biellette
            _patte_y_max = fork_inner_y - 1;  // 6.7, marge 1.3mm vs biellette
            hull() {
                translate([-pt/2,_patte_y_max-3,H_pivot-4]) cube([pt,3,8]);
                translate([-pt/2,fork_inner_y-fork_t-2,H_pivot-4]) cube([pt,2,8]);
            }
            // Fourche D (meme geometrie que fourche B)
            for (fy=[fork_inner_y-fork_t, fork_outer_y])
                translate([-pt/2,fy,H_pivot-5]) cube([pt,fork_t,10]);
            for (fy=[fork_inner_y-fork_t/2, fork_outer_y+fork_t/2])
                translate([0,fy,H_pivot])
                    rotate([-90,0,0]) cylinder(d=10,h=fork_t,center=true);
            // Bossage pivot C
            rotate([0,90,0]) cylinder(d=12,h=pt,center=true);
            // Plateforme pince (face avant +X)
            translate([pt/2, -12, -10]) cube([3, 24, 14]);
        }
        // Pivot C (M3 en Y)
        translate([0,-pw/2-1,0]) rotate([-90,0,0]) cylinder(d=m3, h=pw+2);
        // Pivot D (M3 en Y + fraisage + ecrou)
        translate([0, fork_inner_y-fork_t-1, H_pivot])
            rotate([-90,0,0]) cylinder(d=m3, h=fork_gap+2*fork_t+2);
        translate([0, fork_inner_y-fork_t-0.1, H_pivot])
            rotate([-90,0,0]) cylinder(d=m3_head_d, h=m3_head_h);
        translate([0, fork_outer_y+fork_t-m3_nut_h, H_pivot])
            rotate([-90,30,0]) cylinder(d=m3_nut_d, h=m3_nut_h+0.1, $fn=6);
        // Fixation pince (2xM3 en X)
        for (dy=[-8, 8])
            translate([0, dy, -3]) rotate([0,90,0]) cylinder(d=m3, h=pt+8, center=true);
        for (dy=[-8, 8])
            translate([-pt/2-0.1, dy, -3]) rotate([0,-90,0]) cylinder(d=m3_head_d, h=m3_head_h);
    }
}


// ----- PIECE 7 : Biellette -----
module biellette() {
    difference() {
        hull()
            for (px=[0, L_bras])
                translate([px,0,0]) rotate([-90,0,0]) cylinder(d=biel_d, h=biel_w, center=true);
        for (px=[0, L_bras])
            translate([px,0,0]) rotate([-90,0,0]) cylinder(d=m3, h=biel_w+2, center=true);
    }
}


// =================== SECTION 3b : PINCE (gripper) ==========================

module _machoire_base(phase) {
    difference() {
        union() {
            translate([0,0,jaw_gt]) rotate([180,0,phase])
                gear(number_of_teeth=jaw_n, diametral_pitch=jaw_dp,
                     pressure_angle=jaw_pa, clearance=0.2,
                     gear_thickness=jaw_gt, rim_thickness=jaw_gt, rim_width=6,
                     hub_thickness=jaw_gt, hub_diameter=jaw_hub_d,
                     bore_diameter=jaw_bore_d, circles=0, backlash=jaw_bl);
            hull() {
                cylinder(r=10, h=jaw_gt);
                translate([15,15,0]) cylinder(r=10, h=jaw_gt);
            }
            hull() {
                translate([15,15,0]) cylinder(r=10, h=jaw_gt);
                translate([0,50,0])  cylinder(r=10, h=jaw_gt);
            }
        }
        translate([-4.5,35,-1]) rotate([0,0,-15]) scale([-1,1,1]) cube([20,40,jaw_gt+2]);
        for (i=[-3:1.9:30])
            translate([-4.75+i*sin(15), 35+i*cos(15), -1]) rotate([0,0,30]) cube([2,2,jaw_gt+2]);
    }
}

module machoire_droite() {
    difference() {
        _machoire_base(0);
        translate([0,0,-1]) cylinder(r=2.6, h=jaw_gt+2);
        translate([0,0,jaw_gt-1.6]) rotate([0,0,-45])
            hull() { cylinder(r=3.8,h=2); translate([0,14.6,0]) cylinder(r=2.1,h=2); }
    }
}

module machoire_gauche() {
    mirror([1,0,0])
    difference() {
        _machoire_base(jaw_phase);
        translate([0,0,-1]) cylinder(d=m3+tol_pivot*2, h=jaw_gt+2);
        translate([0,0,-0.1]) cylinder(d=7, h=1);
        translate([0,0,jaw_gt-1+0.1]) cylinder(d=7, h=1);
    }
}

module pince_corps() {
    hw = jaw_off + brk_wall;
    d = brk_depth;  pz = pivot_z_brk;

    difference() {
        union() {
            // Plaque fixation (haut)
            translate([-hw-5, -d/2, -3]) cube([2*hw+10+10, d, 3]);
            // Paroi gauche
            translate([-hw-brk_wall, -d/2, pz-3]) cube([brk_wall, d, -pz+6]);
            // Paroi droite
            translate([hw, -d/2, pz-3]) cube([brk_wall+10, d, -pz+6]);
            // Paroi arriere
            translate([-hw-brk_wall, d/2-brk_wall, pz-3]) cube([2*hw+2*brk_wall+10, brk_wall, -pz+6]);
            // Renforts pivots
            for (x=[-jaw_off, jaw_off])
                translate([x,0,pz]) rotate([90,0,0]) cylinder(d=14, h=d, center=true);
        }
        // Pivots machoires (M3 en Y + fraisage + ecrou)
        for (x=[-jaw_off, jaw_off]) {
            translate([x,-d/2-0.1,pz]) rotate([-90,0,0]) cylinder(d=m3, h=d+0.2);
            translate([x,-d/2-0.1,pz]) rotate([-90,0,0]) cylinder(d=m3_head_d, h=m3_head_h);
            translate([x,d/2-m3_nut_h,pz]) rotate([-90,30,0]) cylinder(d=m3_nut_d, h=m3_nut_h+0.1, $fn=6);
        }
        // Degagement engrenages
        translate([-jaw_off+5,-d/2-0.1,pz-15]) cube([2*jaw_off-10, d+0.2, 30]);
        // Passage SG90 (traversee pivot droit pour l'arbre)
        translate([jaw_off,-d/2-0.1,pz]) rotate([-90,0,0]) cylinder(d=14, h=d+0.2);
        // Fixation platine (2xM3)
        for (dx=[-8,8]) translate([dx,0,-3.1]) cylinder(d=m3, h=3.2);
        // Ouverture doigts
        translate([-jaw_off+2,-d/2-0.1,pz-3.1]) cube([2*jaw_off-4, d+0.2, 3.2]);
        // Degagement platine CD — la paroi arriere traversait la platine.
        // En coords locales pince : la platine est a local_z ≈ -pince_x_offset
        // On creuse une encoche dans la paroi arriere pour la laisser passer.
        translate([-(plt_w/2+3), -0.1, -(pince_x_offset + plt_t/2 + 1)])
            cube([plt_w+6, d/2+2, pince_x_offset + plt_t/2 + 1 - 3]);
    }
}

module pince_asm(angle=0) {
    pz = pivot_z_brk;
    color([0.80,0.35,0.35]) pince_corps();
    color([0.85,0.75,0.40])
        translate([jaw_off,-jaw_gt/2,pz]) rotate([-90,0,0]) rotate([0,0,-angle])
            machoire_droite();
    color([0.75,0.65,0.35])
        translate([-jaw_off,-jaw_gt/2,pz]) rotate([-90,0,0]) rotate([0,0,angle])
            machoire_gauche();
    // SG90 : corps vers -Y → +Z en monde (ne gene pas en bas)
    color([0.12,0.12,0.55], 0.6)
        translate([jaw_off, 0, pz]) rotate([-90,0,0]) rotate([0,0,-angle])
            sg90();
}


// ============= SECTION 4 : MODULES DE PLACEMENT (placed_*) =================

module placed_support(a)    { support_epaule(); }
module placed_bras(a)       { rotate([0,-a,0]) bras(); }
module placed_platine(a)    { translate([L_bras*cos(a), 0, L_bras*sin(a)]) platine_cd(); }
module placed_biellette(a)  { translate([0, y_biel_center, H_pivot]) rotate([0,-a,0]) biellette(); }
module placed_pince(a, ap)  {
    Cx = L_bras*cos(a);  Cz = L_bras*sin(a);
    translate([Cx + pince_x_offset, 0, Cz - 3])
        rotate([0,-90,0]) rotate([0,0,90]) pince_asm(ap);
}
module placed_mg996r()      { rotate([-90,0,0]) mg996r(); }
module placed_palonnier(a)  {
    rotate([0,-a,0]) translate([0, y_pal_start, 0]) rotate([-90,0,0]) palonnier_mg996r();
}


// ================== SECTION 5 : ASSEMBLAGE COMPLET ==========================

module assemblage_complet(angle_epaule=45, angle_pince=10) {
    a = angle_epaule;  ap = angle_pince;

    color([0.55,0.70,0.85]) placed_support(a);
    placed_mg996r();
    placed_palonnier(a);
    color([0.55,0.70,0.85]) placed_bras(a);
    color([0.55,0.70,0.85]) placed_platine(a);
    color([0.35,0.78,0.38]) placed_biellette(a);
    placed_pince(a, ap);
}


// ============== SECTION 6 : DETECTION DE COLLISIONS =========================
// Chaque intersection() entre 2 pieces adjacentes est affichee en ROUGE.
// Si vous voyez du rouge → il y a une collision a corriger.

module check_collisions(a=45, ap=10) {
    // Chaque paire a une COULEUR DIFFERENTE pour identifier la source.
    // Rouge vif  = Support vs Bras
    // Orange     = Support vs Biellette
    // Jaune      = Bras vs Platine
    // Vert       = Bras vs Biellette
    // Cyan       = Platine vs Biellette
    // Bleu       = Platine vs Pince
    // Magenta    = Biellette vs Pince
    echo("=== CHECK COLLISIONS ===");

    color("red")     intersection() { placed_support(a); placed_bras(a); }
    color("orange")  intersection() { placed_support(a); placed_biellette(a); }
    color("yellow")  intersection() { placed_bras(a); placed_platine(a); }
    color("lime")    intersection() { placed_bras(a); placed_biellette(a); }
    color("cyan")    intersection() { placed_platine(a); placed_biellette(a); }
    color("blue")    intersection() { placed_platine(a); placed_pince(a, ap); }
    color("magenta") intersection() { placed_biellette(a); placed_pince(a, ap); }

    // --- Faux positifs DESACTIVES ---
    // Bras vs MG996R : l'arbre traverse l'alesage = NORMAL (pas une collision)
    // intersection() { placed_bras(a); placed_mg996r(); }
}

// Balayage multi-angles : verifie a 0, 30, 45, 60, 90 degres
module collision_sweep(ap=10) {
    for (a = [0, 30, 45, 60, 90])
        check_collisions(a, ap);
}


// ===================== SECTION 7 : RENDU ====================================

// --- Assemblage normal ---
assemblage_complet(angle_epaule=45, angle_pince=10);

// --- Detection de collisions (decommenter pour voir les zones rouges) ---
// check_collisions(45, 10);

// --- Balayage multi-angles (decommenter pour test complet) ---
// collision_sweep(10);

// --- Animation ---
// a = 10 + 70*(0.5+0.5*sin($t*360));
// ap = 20*(0.5+0.5*sin($t*360*2));
// assemblage_complet(angle_epaule=a, angle_pince=ap);

// --- Export STL (decommenter UN SEUL) ---
// support_epaule();
// bras();
// platine_cd();
// biellette();
// pince_corps();
// machoire_droite();
// machoire_gauche();
