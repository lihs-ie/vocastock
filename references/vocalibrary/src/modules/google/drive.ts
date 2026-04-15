export const checkToExistImage = async (vocabulary: string): Promise<boolean> => {
    try {
        const uri = process.env.CHECK_IMAGE_API_ENDPOINT;
        const request = `${uri}?vocabulary=${vocabulary}`;

        const response = await fetch(request);

        const json = await response.json();

        return json.hasImage;
    } catch (error) {
        console.log(error);
        return false;
    }
};
