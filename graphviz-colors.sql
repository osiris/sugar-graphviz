SET NAMES UTF8;

DROP TABLE IF EXISTS graphviz_colors;

CREATE TABLE `graphviz_colors` (
  `colorname` varchar(255) NOT NULL,
  UNIQUE KEY `colorname` (`colorname`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS graphviz_tables;

CREATE TABLE `graphviz_tables` (
  `tablename` varchar(255) NOT NULL,
  `colorname` varchar(255) NOT NULL,
  UNIQUE KEY `tablename` (`tablename`,`colorname`)
) ENGINE=InnoDB;

INSERT INTO graphviz_colors (colorname) VALUES ('aquamarine');
INSERT INTO graphviz_colors (colorname) VALUES ('black');
INSERT INTO graphviz_colors (colorname) VALUES ('blue');
INSERT INTO graphviz_colors (colorname) VALUES ('blueviolet');
INSERT INTO graphviz_colors (colorname) VALUES ('brown');
INSERT INTO graphviz_colors (colorname) VALUES ('cadetblue');
INSERT INTO graphviz_colors (colorname) VALUES ('chartreuse');
INSERT INTO graphviz_colors (colorname) VALUES ('chocolate');
INSERT INTO graphviz_colors (colorname) VALUES ('coral');
INSERT INTO graphviz_colors (colorname) VALUES ('cornflowerblue');
INSERT INTO graphviz_colors (colorname) VALUES ('crimson');
INSERT INTO graphviz_colors (colorname) VALUES ('cyan');
INSERT INTO graphviz_colors (colorname) VALUES ('darkgoldenrod');
INSERT INTO graphviz_colors (colorname) VALUES ('darkgreen');
INSERT INTO graphviz_colors (colorname) VALUES ('darkolivegreen');
INSERT INTO graphviz_colors (colorname) VALUES ('darkorange');
INSERT INTO graphviz_colors (colorname) VALUES ('darkorchid');
INSERT INTO graphviz_colors (colorname) VALUES ('darksalmon');
INSERT INTO graphviz_colors (colorname) VALUES ('darkseagreen');
INSERT INTO graphviz_colors (colorname) VALUES ('darkslateblue');
INSERT INTO graphviz_colors (colorname) VALUES ('darkslategray');
INSERT INTO graphviz_colors (colorname) VALUES ('darkturquoise');
INSERT INTO graphviz_colors (colorname) VALUES ('darkviolet');
INSERT INTO graphviz_colors (colorname) VALUES ('deeppink');
INSERT INTO graphviz_colors (colorname) VALUES ('deepskyblue');
INSERT INTO graphviz_colors (colorname) VALUES ('dodgerblue');
INSERT INTO graphviz_colors (colorname) VALUES ('firebrick');
INSERT INTO graphviz_colors (colorname) VALUES ('forestgreen');
INSERT INTO graphviz_colors (colorname) VALUES ('gold');
INSERT INTO graphviz_colors (colorname) VALUES ('goldenrod');
INSERT INTO graphviz_colors (colorname) VALUES ('gray');
INSERT INTO graphviz_colors (colorname) VALUES ('green');
INSERT INTO graphviz_colors (colorname) VALUES ('greenyellow');
INSERT INTO graphviz_colors (colorname) VALUES ('indianred');
INSERT INTO graphviz_colors (colorname) VALUES ('indigo');
INSERT INTO graphviz_colors (colorname) VALUES ('lawngreen');
INSERT INTO graphviz_colors (colorname) VALUES ('lightblue');
INSERT INTO graphviz_colors (colorname) VALUES ('lightsalmon');
INSERT INTO graphviz_colors (colorname) VALUES ('lightseagreen');
INSERT INTO graphviz_colors (colorname) VALUES ('lightskyblue');
INSERT INTO graphviz_colors (colorname) VALUES ('lightslateblue');
INSERT INTO graphviz_colors (colorname) VALUES ('lightslategray');
INSERT INTO graphviz_colors (colorname) VALUES ('limegreen');
INSERT INTO graphviz_colors (colorname) VALUES ('magenta');
INSERT INTO graphviz_colors (colorname) VALUES ('maroon');
INSERT INTO graphviz_colors (colorname) VALUES ('mediumaquamarine');
INSERT INTO graphviz_colors (colorname) VALUES ('mediumblue');
INSERT INTO graphviz_colors (colorname) VALUES ('mediumorchid');
INSERT INTO graphviz_colors (colorname) VALUES ('mediumpurple');
INSERT INTO graphviz_colors (colorname) VALUES ('mediumseagreen');
INSERT INTO graphviz_colors (colorname) VALUES ('mediumslateblue');
INSERT INTO graphviz_colors (colorname) VALUES ('mediumspringgreen');
INSERT INTO graphviz_colors (colorname) VALUES ('mediumturquoise');
INSERT INTO graphviz_colors (colorname) VALUES ('mediumvioletred');
INSERT INTO graphviz_colors (colorname) VALUES ('midnightblue');
INSERT INTO graphviz_colors (colorname) VALUES ('moccasin');
INSERT INTO graphviz_colors (colorname) VALUES ('navy');
INSERT INTO graphviz_colors (colorname) VALUES ('navyblue');
INSERT INTO graphviz_colors (colorname) VALUES ('olivedrab');
INSERT INTO graphviz_colors (colorname) VALUES ('orange');
INSERT INTO graphviz_colors (colorname) VALUES ('orangered');
INSERT INTO graphviz_colors (colorname) VALUES ('orchid');
INSERT INTO graphviz_colors (colorname) VALUES ('palegreen');
INSERT INTO graphviz_colors (colorname) VALUES ('palevioletred');
INSERT INTO graphviz_colors (colorname) VALUES ('peru');
INSERT INTO graphviz_colors (colorname) VALUES ('pink');
INSERT INTO graphviz_colors (colorname) VALUES ('plum');
INSERT INTO graphviz_colors (colorname) VALUES ('powderblue');
INSERT INTO graphviz_colors (colorname) VALUES ('purple');
INSERT INTO graphviz_colors (colorname) VALUES ('red');
INSERT INTO graphviz_colors (colorname) VALUES ('rosybrown');
INSERT INTO graphviz_colors (colorname) VALUES ('royalblue');
INSERT INTO graphviz_colors (colorname) VALUES ('saddlebrown');
INSERT INTO graphviz_colors (colorname) VALUES ('salmon');
INSERT INTO graphviz_colors (colorname) VALUES ('sandybrown');
INSERT INTO graphviz_colors (colorname) VALUES ('seagreen');
INSERT INTO graphviz_colors (colorname) VALUES ('sienna');
INSERT INTO graphviz_colors (colorname) VALUES ('skyblue');
INSERT INTO graphviz_colors (colorname) VALUES ('slateblue');
INSERT INTO graphviz_colors (colorname) VALUES ('slategray');
INSERT INTO graphviz_colors (colorname) VALUES ('springgreen');
INSERT INTO graphviz_colors (colorname) VALUES ('steelblue');
INSERT INTO graphviz_colors (colorname) VALUES ('tomato');
INSERT INTO graphviz_colors (colorname) VALUES ('turquoise');
INSERT INTO graphviz_colors (colorname) VALUES ('violet');
INSERT INTO graphviz_colors (colorname) VALUES ('violetred');
INSERT INTO graphviz_colors (colorname) VALUES ('yellow');
INSERT INTO graphviz_colors (colorname) VALUES ('yellowgreen');

