import sqlalchemy
import streamlit as st
import pandas as pd
import pymysql
import scipy
import plotly.figure_factory as ff
import matplotlib.pyplot as plt
from matplotlib import cm


functions = ['Please Select', 'View Airline Delay Information', 'View Airport Delay Information', 'Find Flights Information', 'Find Flights Delay Information', 'Insert A New Flight Information', 'Update Delayed Information', 'Delete An Exsited Flight']

option = st.sidebar.selectbox('Please select the function you would like to use:', functions)

PY_MYSQL_CONN_DICT = {
    "host" : '127.0.0.1',
    "port" : 3306,
    "user" : 'root',
    "passwd" : '',
    "db" : 'flight_delays'
}
engine = sqlalchemy.create_engine("mysql+pymysql://root:@127.0.0.1:3306/flight_delays")
conn = pymysql.connect(**PY_MYSQL_CONN_DICT)
cusor = conn.cursor(cursor=pymysql.cursors.DictCursor)


if option == 'Please Select':
    st.title("Welcome to Delayed Flights Search")
    st.header("Please Select Any Function You Would Like On the Sidebar! ")
elif option == 'View Airline Delay Information':
    st.title("View Airline Delay Information")
    sql = ' SELECT * FROM airline_delay_summary;'
    airline_delay = pd.read_sql(sql, engine)
    
    norm = plt.Normalize(0,max(list(airline_delay['delay_average'])))
    norm_values = norm(airline_delay['delay_average'])
    map_vir = cm.get_cmap(name='plasma')
    colors = map_vir(norm_values)

    fig, ax = plt.subplots()
    ax.bar(airline_delay['AIRLINE'], height = airline_delay['delay_count'], color=colors)
    ax.set_xlabel("Airline")
    ax.set_ylabel("Delayed Flights Count")
    sm = cm.ScalarMappable(cmap=map_vir,norm=norm)  # norm设置最大最小值
    sm.set_array([])
    plt.colorbar(sm)
    st.pyplot(fig)
    st.table(airline_delay)

elif option == 'View Airport Delay Information':
    st.title("View Airline Delay Information")
    sql = 'SELECT *FROM airport_delay_summary;'
    airport_delay = pd.read_sql(sql, engine)

    norm = plt.Normalize(0,max(list(airport_delay['departure_delay_average'])))
    norm_values = norm(airport_delay['departure_delay_average'])
    map_vir = cm.get_cmap(name='plasma')
    colors = map_vir(norm_values)
    
    fig, ax = plt.subplots()
    ax.scatter(airport_delay['departure_delay_count'], airport_delay['departure_delay_average'])
    ax.set_xlabel("Departure Delay Count")
    ax.set_ylabel("Departure Delay Average")
    ax.set_title("Departure Delay Scatter Plot")
    st.pyplot(fig)

    fig, ax = plt.subplots()
    ax.scatter(airport_delay['arrival_delay_count'], airport_delay['arrival_delay_average'])
    ax.set_xlabel("Arrival Delay Count")
    ax.set_ylabel("Arrival Delay Average")
    ax.set_title("Arrival Delay Scatter Plot")
    st.pyplot(fig)

    st.table(airport_delay)

elif option == 'Find Flights Information':
    st.title("Find Flights Information")
    st.header("This function helps you find out all the flights based on the origin and destination airports. ")
    sql = 'SELECT IATA_CODE from airports'
    airports = list(pd.read_sql(sql, engine)['IATA_CODE'])
    origin = st.sidebar.selectbox('Please select origin airport:', airports)
    dest = st.sidebar.selectbox('Please select destination airport:', airports)
    
    cusor.callproc('findAirlineInfo', args=[origin, dest])
    res1 = cusor.fetchall()
    print(res1)
    flights = pd.DataFrame(columns=('AIRLINE', 'FLIGHT_NUMBER', 'SCHEDULED_DEPARTURE', 'SCHEDULED_ARRIVAL', 'SCHEDULED_TIME'))
    for i in res1:
        flights = flights.append([{'AIRLINE':'%s' % i['AIRLINE'], 
                                 'FLIGHT_NUMBER': '%s' % i['FLIGHT_NUMBER'],
                                 'SCHEDULED_DEPARTURE': '%s' % i['SCHEDULED_DEPARTURE'], 
                                 'SCHEDULED_ARRIVAL': '%s' % i['SCHEDULED_ARRIVAL'],
                                 'SCHEDULED_TIME': '%s' % i['SCHEDULED_TIME']}], ignore_index=True)
    
    st.table(flights)
elif option == 'Find Flights Delay Information':
    st.title("Find Flights Delay Information")
    st.header("This function helps you find out the delayed information of a flight that you specified. Please enter the flight number in the textbook on the sidebar. ")
    flight_number = st.sidebar.text_input('Flight Number (e.g. UA544)')
    if len(flight_number) > 2:
        al = flight_number[:2]
        fn = flight_number[2:]
        #st.write("%s  hahaha %s" % (al, fn))
        cusor.callproc('findFlightsDelayInfo', args=[al, fn])
        res1 = cusor.fetchall()
        if len(res1) == 0:
            st.error("The Airline and Flight Number you entered is not in our database. Please try another one. ")
        else:
            for i in res1:
                st.write("Flight %s, DEPART_DELAY: %s, ARRIVAL_DELAY: %s" % (flight_number, i['DEPARTURE_DELAY'], i['ARRIVAL_DELAY']))
    elif len(flight_number) > 0:
        st.error("The Flight Number You Entered is Not Correct. Please Reenter! ")

elif option == 'Insert A New Flight Information':
    st.title("Insert A New Flight Information")
    st.header("You can insert a new flight by specifying the following information: ")
    AIRLINE = st.text_input('AIRLINE', 'UA')
    FLIGHT_NUMBER = st.text_input('FLIGHT_NUMBER', '289')
    ORIGIN_AIRPORT = st.text_input('ORIGIN_AIRPORT', 'LAX')
    DESTINATION_AIRPORT = st.text_input('DESTINATION_AIRPORT', 'JFK')
    YEAR = st.text_input('YEAR', '2015')
    MONTH = st.text_input('MONTH', '1')
    DAY = st.text_input('DAY', '23')
    SCHEDULED_DEPARTURE = st.text_input('SCHEDULED_DEPARTURE', '00:50:00')
    DISTANCE = st.text_input('DISTANCE', '1416')
    SCHEDULED_ARRIVAL = st.text_input('SCHEDULED_ARRIVAL', '3:15:00')
    clicked =  st.button('Submit')
    if clicked:
        cusor.callproc('insert_schedule_info', args=[YEAR, MONTH, DAY, AIRLINE, FLIGHT_NUMBER, ORIGIN_AIRPORT, DESTINATION_AIRPORT, SCHEDULED_DEPARTURE, DISTANCE, SCHEDULED_ARRIVAL])
        res3 = cusor.fetchall()
        message = res3[0]['message']
        if message == 'Success! ':
            st.success(message + " The schedule time is also updated based on the time you entered. ")
            sql = ' SELECT AIRLINE, FLIGHT_NUMBER, SCHEDULED_TIME FROM schedule_info s1 JOIN scheduled_time_info  s2 ON s1.SCHEDULED_DEPARTURE = s2.SCHEDULED_DEPARTURE AND s1.SCHEDULED_ARRIVAL = s2.SCHEDULED_ARRIVAL WHERE s1.YEAR = %s and s1.MONTH = %s and s1.DAY = %s and s1.AIRLINE = "%s" and s1.FLIGHT_NUMBER = %s and s1.ORIGIN_AIRPORT = "%s" AND s1.DESTINATION_AIRPORT = "%s";' % (YEAR, MONTH, DAY, AIRLINE, FLIGHT_NUMBER, ORIGIN_AIRPORT, DESTINATION_AIRPORT)
            print(sql)
            table = pd.read_sql(sql, engine)
            st.table(table)
        else:
            st.error(message)
elif option == 'Update Delayed Information':
    st.title("Update Delayed Information")
    st.header("For each delayed flight, there are different reason for their delay. So far, we are still missing some delay time about the delayed flights. You can help us improve the data here! ")
    AIRLINE = st.text_input('AIRLINE', 'AA')
    FLIGHT_NUMBER = st.text_input('FLIGHT_NUMBER', '2299')
    ORIGIN_AIRPORT = st.text_input('ORIGIN_AIRPORT', 'JFK')
    DESTINATION_AIRPORT = st.text_input('DESTINATION_AIRPORT', 'MIA')
    YEAR = st.text_input('YEAR', '2015')
    MONTH = st.text_input('MONTH', '1')
    DAY = st.text_input('DAY', '1')
    AIR_SYSTEM_DELAY = st.text_input('AIR_SYSTEM_DELAY', '0')
    SECURITY_DELAY = st.text_input('SECURITY_DELAY', '0')
    AIRLINE_DELAY = st.text_input('AIRLINE_DELAY', '0')
    LATE_AIRCRAFT_DELAY = st.text_input('LATE_AIRCRAFT_DELAY', '0')
    WEATHER_DELAY = st.text_input('WEATHER_DELAY', '0')

    clicked =  st.button('Submit')
    if clicked:
        cusor.callproc('update_delay_info', args=[MONTH, DAY, AIRLINE, FLIGHT_NUMBER, ORIGIN_AIRPORT, DESTINATION_AIRPORT, AIR_SYSTEM_DELAY, SECURITY_DELAY, AIRLINE_DELAY, LATE_AIRCRAFT_DELAY, WEATHER_DELAY])
        res4 = cusor.fetchall()
        message = res4[0]['message']
        if message == 'Success! ':
            st.success(message)
            st.subheader("Updated Information:")
            # cusor.callproc('show_delay_info', args=[MONTH, DAY, AIRLINE, FLIGHT_NUMBER, ORIGIN_AIRPORT, DESTINATION_AIRPORT])
            # res = cusor.fetchall()
            sql = "SELECT AIRLINE, FLIGHT_NUMBER, AIR_SYSTEM_DELAY, SECURITY_DELAY, AIRLINE_DELAY, LATE_AIRCRAFT_DELAY, WEATHER_DELAY FROM delay_info WHERE  MONTH = %s and DAY = %s and AIRLINE = '%s' and FLIGHT_NUMBER = %s" % (MONTH, DAY, AIRLINE, FLIGHT_NUMBER)
            st.table(pd.read_sql(sql, engine))
            st.subheader("History Change: ")
            sql = "SELECT AIR_SYSTEM_DELAY, SECURITY_DELAY, AIRLINE_DELAY, LATE_AIRCRAFT_DELAY, WEATHER_DELAY, changing_time FROM update_delay_change WHERE MONTH = %s and DAY = %s and AIRLINE = '%s' and FLIGHT_NUMBER = %s" % (MONTH, DAY, AIRLINE, FLIGHT_NUMBER)
            st.table(pd.read_sql(sql, engine))
            #st.write(res)
        else:
            cusor.callproc('select_delay_info', args=[MONTH, DAY, AIRLINE, FLIGHT_NUMBER, ORIGIN_AIRPORT, DESTINATION_AIRPORT])
            res4 = cusor.fetchall()
            st.error(message + " The total delay time is %d minutes. " % res4[0]['ARRIVAL_DELAY'])
elif option == 'Delete An Exsited Flight':
    st.title("Delete An Exsited Flight")
    st.header("You may delete a flight. ")
    AIRLINE = st.text_input('AIRLINE', 'UA')
    FLIGHT_NUMBER = st.text_input('FLIGHT_NUMBER', '1224')
    ORIGIN_AIRPORT = st.text_input('ORIGIN_AIRPORT', 'SFO')
    DESTINATION_AIRPORT = st.text_input('DESTINATION_AIRPORT', 'LAX')
    YEAR = st.text_input('YEAR', '2015')
    MONTH = st.text_input('MONTH', '1')
    DAY = st.text_input('DAY', '1')
    clicked =  st.button('Submit')
    if clicked:
        cusor.callproc('deleteAirlineInfo', args=[MONTH, DAY, AIRLINE, FLIGHT_NUMBER, ORIGIN_AIRPORT, DESTINATION_AIRPORT])
        res4 = cusor.fetchall()
        message = res4[0]['message']
        if message == 'Success! ':
            st.success(message)
            st.subheader("The information you deleted: ")
            sql = "SELECT * FROM schedule_change WHERE original_MONTH = %s and original_DAY = %s and original_AIRLINE = '%s' and original_FLIGHT_NUMBER = %s" % (MONTH, DAY, AIRLINE, FLIGHT_NUMBER)
            st.table(pd.read_sql(sql, engine))
        else:
            st.error(message)
#st.table()
