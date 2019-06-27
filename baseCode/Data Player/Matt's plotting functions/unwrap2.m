function ang = unwrap(ang)

ang(ang < -pi) = pi - abs(ang(ang < -pi) + pi);
ang(ang > pi) =  -pi + abs(ang(ang > pi) - pi);
