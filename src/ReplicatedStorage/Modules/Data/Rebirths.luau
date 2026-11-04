--!strict


return {
	Requirements = {
	}
}:: 
{
	Requirements: {
		[string]: {
			getDescription: (x: number) -> (string),
			getNextQuota: (x: number) -> (number),
			path: {string},
			expectedType: number,
		}
	}
}