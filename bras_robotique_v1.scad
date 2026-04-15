// ==========================================================================
// BRAS ROBOTIQUE 2 SERVOS + PARALLELOGRAMME
// MG996R (epaule) — SG90 (pince)
// ==========================================================================
// Sources servo : joeiddon/chess_robot, ledalert/cadmodel-sg90
// Support : inspire Haus1775/kinetic-sand-table
// Pince : inspire tallerinventores/educational-robot-arm-with-6DOF
// ==========================================================================
// Assemblage direct — origine = pivot A (axe MG996R)
// X = avant (bras)   Y = lateral (axe servo)   Z = haut
// ==========================================================================

$fn = 60;
tol = 0.3;

// --- PARALLELOGRAMME (CRITIQUE : bras = biellette, AB = CD) ---
L_bras  = 100;
H_pivot = 30;

// --- VIS ---
m3 = 3.2;
m2 = 2.2;


// =====================================================================
//  MG996R  — axe +Z, origine = centre axe
// =====================================================================
module mg996r() {
    bw = 40.7;  bd = 19.7;  bh = 36.5;
    ear_h = 2.5;  ear_ov = 7.0;  ear_from_bot = 26.5;
    hub_d = 12;  hub_h = 4;  axe_d = 5.8;  axe_h = 3;
    sfb = 32.9; // shaft from body bottom

    color([0.18, 0.18, 0.22]) {
        translate([-bw/2, -bd/2, -sfb]) cube([bw, bd, bh]);
        cylinder(d=hub_d, h=hub_h);
        cylinder(d=axe_d, h=hub_h + axe_h);
        translate([-(bw/2+ear_ov), -bd/2, ear_from_bot - sfb])
            cube([bw + 2*ear_ov, bd, ear_h]);
    }
}


// =====================================================================
//  SG90  — axe +Z, origine = centre axe
// =====================================================================
module sg90() {
    bw = 22.5;  bd = 12.0;  bh = 22.5;
    hub_d = 11;  hub_h = 4;  hub_off = 5.5;
    axe_d = 4.7;  axe_h = 3;
    ear_t = 2;  ear_w = 32.5;  ear_fb = 15.5;
    sfb = bh + hub_h - 1;

    color([0.12, 0.12, 0.55]) {
        translate([-bw/2, -bd/2, -sfb]) cube([bw, bd, bh]);
        translate([0, 0, -sfb + bh - 0.1]) {
            translate([hub_off, 0, 0]) cylinder(d=hub_d, h=hub_h+0.1);
            hull() {
                translate([hub_off, 0, 0]) cylinder(d=5.5, h=hub_h+0.1);
                translate([-hub_off, 0, 0]) cylinder(d=5.5, h=hub_h+0.1);
            }
        }
        cylinder(d=axe_d, h=axe_h);
        translate([-ear_w/2, -bd/2, ear_fb - sfb])
            cube([ear_w, bd, ear_t]);
    }
}


// =====================================================================
// PIECE 1 — Support epaule (compact, U-bracket)
// =====================================================================
// Directement dans le repere assemblage : origine = axe A
// Le servo (apres rotate [-90,0,0]) occupe :
//   X ±20.35   Y -32.9..+7   Z ±9.85
module support_epaule() {
    w  = 3;        // parois
    bt = 4;        // base
    r  = 3;        // rayon coins base

    // Poche servo
    px = 42;       // largeur poche (X)
    py = 35;       // profondeur poche (Y, derriere l'axe)
    pz = 21;       // hauteur poche (Z)

    z_bot  = -(pz/2 + w + bt);      // ~-17.5
    z_side = pz/2 + w;              // ~13.5  (haut parois laterales)
    z_top  = H_pivot + 6;           // 36 (haut plaque avant)

    base_x = px + 2*w + 8;         // 56
    base_y = py + 2*w + 4;         // 45

    difference() {
        union() {
            // --- Base arrondie ---
            hull()
                for (dx = [-(base_x/2-r), base_x/2-r])
                    for (dy = [-(py+w+2-r), (w+2-r)])
                        translate([dx, dy, z_bot])
                            cylinder(r=r, h=bt);

            // --- Parois U-pocket ---
            // Gauche
            translate([-(px/2+w), -(py+w), z_bot+bt])
                cube([w, py+2*w, z_side - z_bot - bt]);
            // Droite
            translate([px/2, -(py+w), z_bot+bt])
                cube([w, py+2*w, z_side - z_bot - bt]);
            // Arriere
            translate([-(px/2+w), -(py+w), z_bot+bt])
                cube([px+2*w, w, z_side - z_bot - bt]);

            // --- Plaque avant (fuselee vers le pivot B) ---
            hull() {
                translate([-(px/2+w), -w, z_bot+bt])
                    cube([px+2*w, w, 0.1]);
                translate([-14, -w, z_top - 0.1])
                    cube([28, w, 0.1]);
            }

            // --- Renforts lateraux (goussets triangulaires) ---
            for (sx = [-(px/2+w), px/2])
                hull() {
                    translate([sx, -w, z_side - 0.1])
                        cube([w, w, 0.1]);
                    translate([sx > 0 ? 14-w : -14, -w, z_top - 0.1])
                        cube([w, w, 0.1]);
                }

            // --- Pivot B : patte + fourche pour biellette ---
            // Patte de la plaque avant vers Y=bielle_y (14mm)
            hull() {
                translate([-7, 0, H_pivot-6])
                    cube([14, 2, 12]);
                translate([-7, 8, H_pivot-5])
                    cube([14, 2, 10]);
            }
            // Fourche : 2 flasques de part et d'autre de la biellette
            // La biellette fait 12mm en Y (de Y=14-6=8 a Y=14+6=20)
            // Flasque interieur (Y=7)
            translate([-7, 7, H_pivot-5])
                cube([14, 3, 10]);
            // Flasque exterieur (Y=20)
            translate([-7, 20, H_pivot-5])
                cube([14, 3, 10]);
            // Bossages cylindriques
            for (fy = [8.5, 21.5])
                translate([0, fy, H_pivot])
                    rotate([-90, 0, 0])
                        cylinder(d=10, h=3, center=true);
        }

        // --- Evidements ---

        // Poche servo (ouverte par le haut)
        translate([-px/2, -py, -pz/2])
            cube([px, py + w + 1, pz]);

        // Encoches oreilles (plus larges que le corps)
        translate([-28, -7, -pz/2])
            cube([56, 3, pz]);

        // Trou axe (passage dans la plaque avant)
        translate([0, -w-0.1, 0])
            rotate([-90, 0, 0])
                cylinder(d=13, h=w+4);

        // Pivot B (M3 traversant les 2 flasques + biellette)
        translate([0, 6, H_pivot])
            rotate([-90, 0, 0])
                cylinder(d=m3, h=20);

        // Vis oreilles (4×M3, entraxe 49×10)
        for (dx = [-49/2, 49/2])
            for (dz = [-10/2, 10/2])
                translate([dx, -py-w-0.1, dz])
                    rotate([-90, 0, 0])
                        cylinder(d=m3, h=py+2*w+0.2);

        // Fixation chassis (4×M3)
        for (dx = [-18, 18])
            for (dy = [-13, 13])
                translate([dx, -(py/2+w)+dy, z_bot-0.1]) {
                    cylinder(d=m3, h=bt+0.2);
                    cylinder(d=10, h=2.1);  // empreinte silent block
                }

        // Passage cable
        translate([-4, -py-w-0.1, -pz/2])
            cube([8, w+0.2, 4]);
    }
}


// =====================================================================
// PIECE 2 — Bras principal (tube A→C uniquement)
// =====================================================================
// Le bras va de A (X=0) a C (X=L_bras). Pas de pivot D ici.
// D est sur la platine_cd (piece separee, reste verticale).
module bras() {
    L = L_bras;
    sx = 15;  sz = 12;  w = 2.5;
    rl = 15;  re = 18;

    difference() {
        union() {
            // Tube creux (de X=0 a X=L)
            difference() {
                translate([0, -sx/2, -sz/2]) cube([L, sx, sz]);
                translate([rl, -(sx/2-w), -(sz/2-w)])
                    cube([L-rl+0.1, sx-2*w, sz-2*w]);
            }
            // Renfort epaule (X=-8 a X=rl, centre sur l'axe servo a X=0)
            hull() {
                translate([-8, -re/2, -re/2]) cube([8, re, re]);
                translate([rl, -sx/2, -sz/2]) cube([0.1, sx, sz]);
            }
            // Embout C (fin du bras, pivot pour la platine)
            translate([L-3, -sx/2-2, -sz/2-2])
                cube([3, sx+4, sz+4]);
            // Nervure
            translate([rl, -1, -sz/2-2]) cube([L-rl-3, 2, 2]);
        }

        // Axe servo a X=0 (centre de rotation !)
        translate([0, -re/2-0.1, 0])
            rotate([-90, 0, 0]) cylinder(d=6.1, h=re+0.2);
        // Vis palonnier (dessus, a X=0)
        translate([0, 0, re/2-0.1]) cylinder(d=m3, h=4);
        // Pivot C (M3, trou traversant en X pour la platine)
        translate([L-3-0.1, 0, 0])
            rotate([0, 90, 0]) cylinder(d=m3, h=4);
    }
}


// =====================================================================
// PIECE 2b — Platine CD (reste verticale, porte la pince)
// =====================================================================
// Barre verticale de C (Z=0) a D (Z=H_pivot).
// C = pivot sur le bras. D = pivot pour la biellette.
// La pince se fixe en bas. La biellette en haut.
module platine_cd() {
    pt = 5;  pw = 20;
    by = 14;  // offset Y biellette

    difference() {
        union() {
            // Barre verticale C→D
            hull() {
                translate([-pt/2, -pw/2, -2])
                    cube([pt, pw, 4]);
                translate([-pt/2, -pw/2, H_pivot-2])
                    cube([pt, pw, 4]);
            }
            // Patte laterale vers la biellette (Y=by) en haut
            hull() {
                translate([-pt/2, pw/2-2, H_pivot-4])
                    cube([pt, 2, 8]);
                translate([-pt/2, by-7, H_pivot-4])
                    cube([pt, 2, 8]);
            }
            // Fourche pivot D : 2 flasques autour de la biellette
            // Biellette = 12mm en Y, centree sur Y=by (Y=8 a Y=20)
            // Flasque interieur
            translate([-pt/2, by-6-3, H_pivot-5])
                cube([pt, 3, 10]);
            // Flasque exterieur
            translate([-pt/2, by+6, H_pivot-5])
                cube([pt, 3, 10]);
            // Bossages cylindriques sur chaque flasque
            for (fy = [by-6-1.5, by+6+1.5])
                translate([0, fy, H_pivot])
                    rotate([-90, 0, 0])
                        cylinder(d=10, h=3, center=true);
            // Bossage C
            translate([0, 0, 0])
                rotate([0, 90, 0])
                    cylinder(d=12, h=pt, center=true);
            // Plateforme pince (sous C)
            translate([-pt/2, -pw/2, -8])
                cube([pt, pw, 8]);
        }
        // Pivot C (M3, axe X — liaison bras)
        rotate([0, 90, 0])
            cylinder(d=m3, h=pt+2, center=true);
        // Pivot D (M3 traversant les 2 flasques + biellette)
        translate([0, by-10, H_pivot])
            rotate([-90, 0, 0])
                cylinder(d=m3, h=20);
        // Fixation pince (2×M2)
        for (dy = [-27.5/2, 27.5/2])
            translate([-pt/2-0.1, dy, -4])
                rotate([0, 90, 0]) cylinder(d=m2, h=pt+0.2);
    }
}


// =====================================================================
// PIECE 3 — Corps de pince (compact, arrondi)
// =====================================================================
// Z=0 haut (fixation bras), vers -Z. Largeur en Y.
module corps_pince() {
    cw = 50;  cd = 22;  ch = 25;
    sp_l = 23.1;  sp_w = 12.6;  sp_h = 23.1;
    fp_sp = 35;  fp_z = -ch + 7;  // -18
    ear_w = 33;
    cr = 3;
    wall = 3;

    // Le corps a 2 zones :
    //   Haut (Z=-15 a 0) : boitier ferme, logement SG90
    //   Bas  (Z=-25 a -15) : cadre ouvert, mecanisme visible
    //     Seules les 2 joues laterales (pivots doigts) restent pleines
    //     Le centre est ouvert pour le palonnier et les biellettes

    difference() {
        union() {
            // === Zone haute : boitier SG90 ===
            hull()
                for (dy = [-(cw/2-cr), cw/2-cr])
                    for (dx = [-(cd/2-cr), cd/2-cr])
                        translate([dx, dy, -15])
                            cylinder(r=cr, h=15);

            // === Zone basse : 2 joues laterales ===
            // Joue gauche (porte le pivot doigt gauche)
            hull() {
                translate([-(cd/2-cr), -(cw/2-cr), -ch])
                    cylinder(r=cr, h=ch);
                translate([(cd/2-cr), -(cw/2-cr), -ch])
                    cylinder(r=cr, h=ch);
                translate([-(cd/2-cr), -(fp_sp/2-5), -ch])
                    cylinder(r=cr, h=ch);
                translate([(cd/2-cr), -(fp_sp/2-5), -ch])
                    cylinder(r=cr, h=ch);
            }
            // Joue droite
            hull() {
                translate([-(cd/2-cr), (cw/2-cr), -ch])
                    cylinder(r=cr, h=ch);
                translate([(cd/2-cr), (cw/2-cr), -ch])
                    cylinder(r=cr, h=ch);
                translate([-(cd/2-cr), (fp_sp/2-5), -ch])
                    cylinder(r=cr, h=ch);
                translate([(cd/2-cr), (fp_sp/2-5), -ch])
                    cylinder(r=cr, h=ch);
            }

            // Pattes fixation bras (dessus)
            for (dy = [-27.5/2, 27.5/2])
                translate([0, dy, 0]) cylinder(d=7, h=3);
        }

        // Logement SG90
        translate([-sp_l/2, -sp_w/2, -sp_h+1])
            cube([sp_l, sp_w, sp_h+0.1]);

        // Fente oreilles SG90
        translate([-ear_w/2, -sp_w/2, -10])
            cube([ear_w, sp_w, 2]);

        // Passage axe SG90 (a travers le plancher de la zone haute)
        translate([0, 0, -16])
            cylinder(d=10, h=3);

        // Pivots doigts (2×M3 en Z, dans les joues)
        for (dy = [-fp_sp/2, fp_sp/2])
            translate([0, dy, -ch - 0.1])
                cylinder(d=m3, h=15);

        // Fixation bras (M2)
        for (dy = [-27.5/2, 27.5/2])
            translate([0, dy, -0.1]) cylinder(d=m2, h=3.2);
    }
}


// =====================================================================
// PIECE 4 — Doigt de pince
// =====================================================================
// Origine au pivot (axe Z). Le doigt pend vers -Z.
// Un bras interne (vers Y=0) recoit la poussee du palonnier.
module doigt(miroir = false) {
    dl = 50;  dw = 12;  dt = 5;
    above = 8;  below = dl - above;
    bras_int = 10;  // longueur du bras interne (vers le centre, pousse par le palonnier)

    s = miroir ? -1 : 1;
    scale([1, s, 1])
    difference() {
        union() {
            // Doigt principal (pend vers -Z)
            hull() {
                translate([-dt/2, -dw/2, -below])
                    cube([dt, dw, dl - 5]);
                cylinder(d=dw, h=above);
            }
            // Patte grip elargie
            hull() {
                translate([-dt/2, -dw/2, -below])
                    cube([dt, dw, 3]);
                translate([-dt/2, -(dw/2+2), -below-2])
                    cube([dt, dw+4, 2]);
            }
            // Bras interne (vers Y=0, pousse par le palonnier)
            hull() {
                cylinder(d=dw, h=above);
                translate([0, -bras_int, 0])
                    cylinder(d=8, h=above);
            }
        }
        // Pivot M3 (axe Z — le doigt pivote dans le plan XY)
        translate([0, 0, -1])
            cylinder(d=m3, h=above + 2);
        // Trou biellette M2 (sur le bras interne)
        translate([0, -bras_int, -1])
            cylinder(d=m2, h=above + 2);
        // Encoche TPU
        translate([-dt/2-0.1, -5, -below])
            cube([3.1, 10, 15]);
    }
}


// =====================================================================
// PIECES TPU (4b, 5, 6)
// =====================================================================
module embout_tpu() {
    difference() {
        cube([3, 12, 15]);
        for (i = [0:5])
            translate([-0.1, 1+i*2, 1]) cube([1.5, 0.8, 13]);
    }
}

module butee_tpu() {
    hull()
        for (x=[1,9]) for (y=[1,7])
            translate([x,y,0]) cylinder(r=1, h=3);
}

module silent_block() {
    difference() {
        cylinder(d=10, h=2);
        translate([0,0,-0.1]) cylinder(d=m3, h=2.2);
    }
}


// =====================================================================
// PIECE 7 — Biellette parallelogramme
// =====================================================================
module biellette() {
    L = L_bras;  bw = 12;  bh = 8;  boss = 14;

    difference() {
        union() {
            // Corps
            translate([0, -bw/2, -bh/2]) cube([L, bw, bh]);
            for (px = [0, L])
                translate([px, 0, 0])
                    rotate([-90, 0, 0])
                        cylinder(d=boss, h=bw, center=true);
        }
        for (px = [0, L])
            translate([px, 0, 0])
                rotate([-90, 0, 0])
                    cylinder(d=m3, h=bw+2, center=true);
    }
}


// =====================================================================
// ASSEMBLAGE COMPLET
// =====================================================================
module assemblage_complet(angle_epaule = 45, angle_pince = 25) {

    col_s = [0.3, 0.6, 0.9];    // structure PETG
    col_b = [0.35, 0.78, 0.38]; // biellette
    col_t = [0.95, 0.55, 0.15]; // TPU
    col_p = [0.8, 0.35, 0.35];  // pince

    a  = angle_epaule;
    Cx = L_bras * cos(a);
    Cz = L_bras * sin(a);

    by = 14;  // offset Y biellette

    // === SUPPORT (deja dans le bon repere) ===
    color(col_s) support_epaule();

    // === SILENT BLOCKS ===
    z_bot = -(21/2 + 3 + 4);
    color(col_t)
        for (dx=[-18,18]) for (dy=[-13,13])
            translate([dx, -(35/2+3)+dy, z_bot - 2])
                silent_block();

    // === MG996R (axe +Y) ===
    rotate([-90, 0, 0]) mg996r();

    // === BRAS (tube de A a C) ===
    color(col_s)
        rotate([0, -a, 0]) bras();

    // === PLATINE CD au point C (reste VERTICALE — cle du parallelogramme) ===
    // C = [Cx, 0, Cz], D = [Cx, by, Cz + H_pivot]
    translate([Cx, 0, Cz]) {
        color(col_s) platine_cd();
    }

    // === BIELLETTE de B a D ===
    // B = [0, by, H_pivot], direction = meme que le bras
    // D = B + L*[cos(a), 0, sin(a)] = [Cx, by, Cz + H_pivot] ✓
    color(col_b)
        translate([0, by, H_pivot])
        rotate([0, -a, 0])
            biellette();

    // === PINCE au point C (horizontale, ouverte vers +X) ===
    translate([Cx, 0, Cz])
    rotate([0, -90, 0])
    {
        color(col_p) corps_pince();

        // SG90 retourne (axe vers le bas = -Z)
        translate([0, 0, -2])
            rotate([180, 0, 0]) sg90();

        // === MECANISME PINCE ===
        // Le SG90 (axe -Z) entraine un palonnier dans le plan XY.
        // Le palonnier pousse les bras internes des doigts.
        // Les doigts pivotent autour de Z → meme plan → ca marche.

        fp_sp = 35;               // ecart pivots doigts (Y)
        fp_z  = -25 + 7;          // -18 : Z pivot doigts
        horn_z = -17;              // Z du palonnier (zone ouverte)
        horn_r = 15;               // rayon palonnier
        bras_int = 10;             // bras interne du doigt

        // Angle du palonnier (lie a l'ouverture pince)
        horn_a = angle_pince * 0.4;

        // Arbre prolonge (SG90 → palonnier)
        color([0.7, 0.7, 0.72])
        translate([0, 0, horn_z])
            cylinder(d=3, h=-horn_z - 2);

        // Palonnier (blanc, 2 bras vers les doigts)
        color([0.95, 0.95, 0.95])
        translate([0, 0, horn_z]) {
            cylinder(d=8, h=4);   // moyeu
            rotate([0, 0, horn_a])
            for (s = [-1, 1])
                hull() {
                    cylinder(d=6, h=3);
                    translate([0, s*horn_r, 0]) cylinder(d=5, h=3);
                }
        }

        // Biellettes (tiges du palonnier aux bras internes des doigts)
        for (side = [-1, 1]) {
            // Bout du palonnier
            hp_y = side * horn_r * cos(horn_a);
            hp_x = -side * horn_r * sin(horn_a);

            // Bout du bras interne du doigt
            // Le doigt pivote en Z de side*angle_pince/2 a [0, side*fp_sp/2, fp_z]
            // Le bras interne va vers Y=0 de bras_int mm
            da = side * angle_pince / 2;
            d_y = side*fp_sp/2 - bras_int * cos(da) * side;
            d_x = bras_int * sin(da) * side;

            color([0.55, 0.55, 0.6])
            hull() {
                translate([hp_x, hp_y, horn_z + 1.5]) sphere(d=3);
                translate([d_x, d_y, fp_z + 4])       sphere(d=3);
            }
        }

        // === DOIGTS (pivotent autour de Z dans le plan XY) ===
        for (side = [-1, 1]) {
            color(col_s)
            translate([0, side*fp_sp/2, fp_z])
            rotate([0, 0, side*angle_pince/2])
                doigt(miroir = (side > 0));

            color(col_t)
            translate([0, side*fp_sp/2, fp_z])
            rotate([0, 0, side*angle_pince/2])
            translate([-1.5, -6, -42])
                embout_tpu();
        }
    }

    // === BUTEES ===
    color(col_t) {
        translate([-5, -2, H_pivot-4]) butee_tpu();
        translate([8, -2, -7])         butee_tpu();
    }
}


// =====================================================================
// RENDU
// =====================================================================
assemblage_complet(angle_epaule = 45, angle_pince = 25);

// Animation : View > Animate (FPS=10, Steps=100)
// a = 10 + 70*(0.5 + 0.5*sin($t*360));
// assemblage_complet(angle_epaule=a, angle_pince=25);

// =====================================================================
// EXPORT STL (decommenter UN SEUL)
// =====================================================================
// support_epaule();
// bras();
// platine_cd();
// corps_pince();
// doigt(miroir=false);
// doigt(miroir=true);
// embout_tpu();
// butee_tpu();
// silent_block();
// biellette();
