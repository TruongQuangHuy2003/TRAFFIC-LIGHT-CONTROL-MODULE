module top (
	input wire clk,
	input wire rst_n,
	input wire [3:0] time_slot,
	input wire sensor_car,
	input wire sensor_pedestrian,
	input wire emergency,
	output reg [2:0] light_NS,
	output reg [2:0] light_EW,	//RED: 3'b100, YELLOW: 3'b010, GREEN: 3'b001
	output reg pedestrian_signal
);

localparam IDLE = 3'b000;
localparam NS_GREEN_EW_RED = 3'b001;
localparam NS_YELLOW_EW_RED = 3'b010;
localparam EW_GREEN_NS_RED = 3'b011;
localparam EW_YELLOW_NS_RED = 3'b100;
localparam PEDESTRIAN_CROSSING = 3'b101;
localparam EMERGENCY = 3'b000;

reg [2:0] state, next_state;
reg [3:0] timer;

initial begin
	light_NS = 3'b100;
	light_EW = 3'b100;
	pedestrian_signal = 1'b0;
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		state <= IDLE;
		timer <= 4'h0;
	end else begin
		state <= next_state;
		if (state != next_state) begin
			timer <= 4'h0;
		end else if (timer < time_slot) begin
			timer <= timer + 1'b1;
		end else begin
			timer <= 4'h0;
		end
	end
end

always @(*) begin
	case (state) 
		IDLE: begin
			next_state <= (emergency) ? EMERGENCY : ((sensor_pedestrian) ? PEDESTRIAN_CROSSING : ((sensor_car) ? NS_GREEN_EW_RED : IDLE));
		end
		NS_GREEN_EW_RED: begin
			next_state <= (timer >= time_slot) ? NS_YELLOW_EW_RED : NS_GREEN_EW_RED;
		end
		NS_YELLOW_EW_RED: begin
			next_state <= (timer >= 2'b10) ? EW_GREEN_NS_RED : NS_YELLOW_EW_RED;
		end
		EW_GREEN_NS_RED: begin
			next_state <= (timer >= time_slot) ? EW_YELLOW_NS_RED : EW_GREEN_NS_RED;
		end
		EW_YELLOW_NS_RED: begin
			next_state <= (timer >= 2'b10) ? IDLE : EW_YELLOW_NS_RED;
		end
		PEDESTRIAN_CROSSING: begin
			next_state <= (timer >= time_slot) ? IDLE : PEDESTRIAN_CROSSING;
		end
		EMERGENCY: begin
			next_state <= (emergency) ? EMERGENCY : IDLE;
		end
		default: next_state <= IDLE;
	endcase
end

always @(*) begin
	if(!rst_n) begin
		light_NS <= 3'b100;	//RED
		light_EW <= 3'b100;	//RED;
		pedestrian_signal <= 1'b0;
	end else begin
		case (state)
			NS_GREEN_EW_RED: begin
				light_NS <= 3'b001;	//GREEN;
				light_EW <= 3'b100;
				pedestrian_signal <= 1'b0;
			end
			NS_YELLOW_EW_RED: begin
				light_NS <= 3'b010;
				light_EW <= 3'b100;
				pedestrian_signal <= 1'b0;
			end
			EW_GREEN_NS_RED: begin
				light_NS <= 3'b100;
				light_EW <= 3'b001;
				pedestrian_signal <= 1'b0;
			end
			EW_YELLOW_NS_RED: begin
				light_NS <= 3'b100;
				light_EW <= 3'b010;
				pedestrian_signal <= 1'b0;
			end
			PEDESTRIAN_CROSSING: begin
				light_NS <= 3'b100;
				light_EW <= 3'b100;
				pedestrian_signal <= 1'b1;
			end
			EMERGENCY: begin
				light_NS <= 3'b100;
				light_EW <= 3'b100;
				pedestrian_signal <= 1'b0;
			end
		endcase
	end
end

endmodule
