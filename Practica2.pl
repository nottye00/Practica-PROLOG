% ============================
% SISTEMA DE VENTAS DE VEHÍCULOS - PRÁCTICA II
% ============================

% ----- PARTE 1: Catálogo de vehículos -----

vehicle(toyota, corolla, sedan, 22000, 2021).
vehicle(toyota, rav4, suv, 28000, 2022).
vehicle(ford, mustang, sport, 45000, 2023).
vehicle(ford, escape, suv, 27000, 2020).
vehicle(bmw, x5, suv, 60000, 2021).
vehicle(bmw, serie3, sedan, 40000, 2022).
vehicle(chevrolet, silverado, pickup, 35000, 2019).
vehicle(chevrolet, camaro, sport, 43000, 2023).
vehicle(honda, civic, sedan, 21000, 2020).
vehicle(honda, crv, suv, 29000, 2021).

% ----- PARTE 2: Consultas básicas y filtros -----

% Filtrar vehículos dentro del presupuesto
meet_budget(Referencia, PresupuestoMax) :-
    vehicle(_, Referencia, _, Precio, _),
    Precio =< PresupuestoMax.

% Listar referencias por marca
vehicles_by_brand(Marca, ListaReferencias) :-
    findall(Referencia, vehicle(Marca, Referencia, _, _, _), ListaReferencias).

% Agrupar por marca y tipo
vehicles_grouped_by_type(Marca, Lista) :-
    bagof((Referencia, Tipo), vehicle(Marca, Referencia, Tipo, _, _), Lista).

% ----- PARTE 3: Generación de reportes -----

% Reporte general por marca, tipo y presupuesto
generate_report(Marca, Tipo, Presupuesto, ResultadoFinal) :-
    findall((Ref, Precio),
            (vehicle(Marca, Ref, Tipo, Precio, _), Precio =< Presupuesto),
            VehiculosFiltrados),
    total_valor(VehiculosFiltrados, Total),
    ajustar_si_excede(VehiculosFiltrados, Total, ResultadoFinal).

% Sumar total del inventario filtrado
total_valor([], 0).
total_valor([(_, Precio) | T], Total) :-
    total_valor(T, Subtotal),
    Total is Precio + Subtotal.

% Limitar el inventario a máximo $1.000.000 si se excede
ajustar_si_excede(Vehiculos, Total, Vehiculos) :-
    Total =< 1000000, !.

ajustar_si_excede(Vehiculos, _, VehiculosAjustados) :-
    sort(2, @=<, Vehiculos, OrdenadosPorPrecio),
    ajustar_lista(OrdenadosPorPrecio, 0, VehiculosAjustados).

% Ir agregando vehículos mientras no se exceda el millón
ajustar_lista([], _, []).
ajustar_lista([(Ref, Precio)|T], Acum, [(Ref, Precio)|Resto]) :-
    NuevoTotal is Acum + Precio,
    NuevoTotal =< 1000000,
    ajustar_lista(T, NuevoTotal, Resto).
ajustar_lista(_, Acum, []) :-
    Acum >= 1000000.

% ----- PARTE 4: Casos de prueba -----

% Caso 1: Toyota SUV menores a $30,000
caso_1(Resultado) :-
    findall(Referencia,
            (vehicle(toyota, Referencia, suv, Precio, _), Precio < 30000),
            Resultado).

% Caso 2: Vehículos Ford agrupados por tipo y año
caso_2(Resultado) :-
    bagof((Tipo, Año, Referencia),
          vehicle(ford, Referencia, Tipo, _, Año),
          Resultado).

% Caso 3: Sedanes sin exceder $500,000
caso_3(Resultado, TotalFinal) :-
    findall((Ref, Precio),
            (vehicle(_, Ref, sedan, Precio, _), Precio =< 500000),
            Lista),
    total_valor(Lista, Total),
    ajustar_si_excede(Lista, Total, Resultado),
    total_valor(Resultado, TotalFinal).