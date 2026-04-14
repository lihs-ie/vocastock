const createPrompt = (vocabulary: string) => {
    return `"${vocabulary}" Please generate an image that visually represents this word. If you have trouble expressing yourself, create an original sentence using that vocabulary and generate an image that visually represents it. Any style of image is fine.`;
};

type Response = {
    created: number;
    data: Array<{
        revised_prompt: string;
        url: string;
    }>;
};

export const getImage = async (vocabulary: string): Promise<string> => {
    try {
        const uri = process.env.OPENAI_IMAGE_API_ENDPOINT;

        if (!uri) {
            throw new Error('Open AI API endpoint is not defined');
        }

        const headers = {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${process.env.OPENAI_API_KEY}`,
        };

        const prompt = createPrompt(vocabulary);

        const data = {
            model: 'dall-e-3',
            size: '1024x1024',
            prompt,
            n: 1,
            quality: 'standard',
        };

        const response = await fetch(uri, {
            method: 'POST',
            headers,
            body: JSON.stringify(data),
        });

        const rawMedia = (await response.json()) as Response;

        console.log('------ Open AI Image Response ------');
        console.log(rawMedia);
        console.log('------------------------------------');

        const savedUrl = await saveImage(vocabulary, rawMedia.data[0].url);

        return savedUrl;
    } catch (error) {
        console.log(error);
        throw new Error('Failed to get image');
    }
};

const saveImage = async (vocabulary: string, imageUrl: string): Promise<string> => {
    try {
        const uri = process.env.SAVING_IMAGE_API_ENDPOINT;

        const request = `${uri}?vocabulary=${vocabulary}&imageUrl=${encodeURIComponent(imageUrl)}`;

        console.log(`---- save image ----`);
        console.log(`request: ${request}`);

        const response = await fetch(request);

        const json = await response.json();

        return json.imageUrl;
    } catch (error) {
        console.log(error);
        throw new Error('Failed to save image');
    }
};
